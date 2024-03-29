"""Text data."""

import re
import string
import typing as tp
from pathlib import Path

import torch
from omegaconf import OmegaConf


class BaseTextEncoder:
    """Base text encoder."""

    def __init__(
        self: "BaseTextEncoder",
        alphabet: tp.List[str],
    ) -> None:
        """Constructor.

        Args:
            alphabet (List): Alphabet used for tokenization.
        """
        self.idx_to_char = {k: v for k, v in enumerate(sorted(alphabet))}
        self.char_to_idx = {v: k for k, v in enumerate(sorted(alphabet))}

    def __getitem__(
        self: "BaseTextEncoder",
        key: tp.Union[int, str],
    ) -> tp.Union[int, str]:
        """Get value from idx_to_char or char_to_idx based on the key type.

        Args:
            key (int, str): The key to get the associated value.

        Returns:
            The value.
        """
        if isinstance(key, int):
            return self.idx_to_char[key]
        elif isinstance(key, str):
            return self.char_to_idx[key]

    def encode(self: "BaseTextEncoder", text: str) -> torch.Tensor:
        """Encode text according to char_to_idx mapping.

        Args:
            text (str): Text to encode.

        Raises:
            Exception: If encoding fails due to unknown characters.

        Returns:
            Tensor: Encoded text.
        """
        text = self.preprocess_text(text)
        try:
            return torch.Tensor([self.char_to_idx[char] for char in text]).unsqueeze(dim=0)
        except KeyError:
            unknown_chars = {char for char in text if char not in self.char_to_idx}
            raise Exception(
                "Cannot encode text:\n{text}.\nUnknown chars: {unknown_chars}.".format(
                    text=text,
                    unknown_chars=", ".join(unknown_chars),
                )
            )

    def decode(self: "BaseTextEncoder", idxs: torch.Tensor) -> str:
        """Decodes the encoded text according to idx_to_char mapping.

        Args:
            idxs (Tensor): Encoded text.

        Returns:
            str: Decoded text.
        """
        return "".join([self.idx_to_char[int(idx)] for idx in idxs])

    @property
    def alphabet_length(self: "BaseTextEncoder") -> int:
        """Get the length of the alphabet used in the tokenization.

        Returns:
            int: Alphabet length.
        """
        return len(self.idx_to_char)

    @staticmethod
    def get_simple_alphabet() -> tp.List[str]:
        """Get the most simple alphabet.

        Returns:
            List: Simple alphabet.
        """
        return list(string.ascii_lowercase + " ")

    @staticmethod
    def preprocess_text(text: str) -> str:
        """Preprocess text before using it with the tokenizer.

        Args:
            text (str): Text to preprocess.

        Returns:
            str: Preprocessed text that is ready to be tokenized.
        """
        # NB: Can be changed to increase an ASR model performance
        text = re.sub(r"[^\w\s]", " ", text.lower())
        text = re.sub(r"\s+", " ", text)
        return text.strip()

    @classmethod
    def from_yaml(cls: "BaseTextEncoder", file: str) -> "BaseTextEncoder":
        """Construct the tokenizer from the YAML file.

        Args:
            file (str): The YAML file.

        Raises:
            Exception: If the file extension is not YAML.

        Returns:
            Base tokenizer.
        """
        if not file.endswith(".yaml") or not file.endswith(".yml"):
            raise Exception("Provide a file with a .yaml or .yml extension.")
        with Path(file).open() as file:
            char_to_idx = OmegaConf.load(file)
            base_tokenizer = cls(list(char_to_idx.keys()))
        return base_tokenizer


class CTCTextEncoder(BaseTextEncoder):
    """Text encoder for Connectionist Temporal Classification."""

    def __init__(
        self: "CTCTextEncoder",
        alphabet: tp.List[str],
    ) -> None:
        """Constructor.

        Args:
            alphabet (List): Alphabet used for tokenization with blank token ϵ.
        """
        super().__init__(alphabet)
        self.blank_idx = self.char_to_idx["ϵ"]

    @staticmethod
    def get_simple_ctc_alphabet() -> tp.List[str]:
        """Get the most simple alphabet for CTC.

        Returns:
            List: Simple alphabet.
        """
        return list(string.ascii_lowercase + " " + "ϵ")

    def ctc_decode(self: "CTCTextEncoder", idxs: torch.Tensor) -> str:
        """Decodes the encoded text according to idx_to_char mapping.

        Args:
            idxs (Tensor): Encoded text with blank token.

        Returns:
            str: Decoded text without blank token.
        """
        encoded_text = []
        for i, idx in enumerate(idxs):
            idx = int(idx)
            if idx == self.blank_idx:
                continue
            if i > 0:
                if idxs[i] == idxs[i - 1]:
                    continue
            encoded_text.append(idx)
        return "".join([self.idx_to_char[idx] for idx in encoded_text])

    def ctc_beam_search(  # NOQA
        self: "CTCTextEncoder",
        probs: torch.Tensor,
        *,
        beam_size: int,
    ) -> tp.List[tp.Tuple[str, float]]:
        pass
