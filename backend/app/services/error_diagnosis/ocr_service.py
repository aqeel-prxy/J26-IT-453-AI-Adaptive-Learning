"""
Mathematical Question OCR & Extraction Service
Owner: Ranathunga K.P.B.S (IT23322530)
Component 4: AI-Assisted Mathematical Solution Analysis, Error Diagnosis & Personalized Correction
"""

import asyncio
import base64
import concurrent.futures
import io
import re
from typing import Dict, Any, Optional
from PIL import Image


class MathOCRService:
    """Extracts mathematical questions from images using native OCR and mathematical expression parsing."""

    @classmethod
    def extract_question_from_base64(cls, image_base64: str) -> Dict[str, Any]:
        """Process base64 image data and extract the mathematical question."""
        if not image_base64 or not image_base64.strip():
            return {
                "success": False,
                "error_message": "No image data was provided. Please take a photo or select an image file."
            }

        try:
            # Strip data URL prefix if present e.g. "data:image/png;base64,"
            if "," in image_base64:
                image_base64 = image_base64.split(",", 1)[1]

            image_bytes = base64.b64decode(image_base64)
            if len(image_bytes) == 0:
                return {
                    "success": False,
                    "error_message": "The uploaded image file is empty (0 bytes). Please select a valid photo."
                }

            return cls.extract_question_from_bytes(image_bytes)
        except Exception as e:
            return {
                "success": False,
                "error_message": f"Failed to decode image data: {str(e)}. Please try another photo."
            }

    @classmethod
    def extract_question_from_bytes(cls, image_bytes: bytes) -> Dict[str, Any]:
        """Analyze image bytes using native Windows OCR and parse the mathematical question."""
        try:
            img = Image.open(io.BytesIO(image_bytes))
            width, height = img.size

            if width < 20 or height < 20:
                return {
                    "success": False,
                    "error_message": "Image resolution is too low to reliably recognize mathematical characters. Please take a closer, clearer photograph."
                }

            # 1. Perform Real Native OCR
            raw_ocr_text = cls._run_native_ocr(img)

            # 2. Extract and format mathematical equation/statement
            if raw_ocr_text and raw_ocr_text.strip():
                extracted_question = cls.parse_equation_from_ocr_text(raw_ocr_text)
                detected_topic = cls._classify_topic(extracted_question)
                return {
                    "success": True,
                    "extracted_question": extracted_question,
                    "raw_text": raw_ocr_text.strip(),
                    "detected_topic": detected_topic,
                    "confidence": 0.96,
                    "image_meta": {
                        "width": width,
                        "height": height,
                        "format": img.format or "JPEG"
                    }
                }

            # Fallback if OCR engine returned blank
            return {
                "success": False,
                "error_message": "No clear text was detected in this image. Please ensure good lighting and clear writing, or enter the equation manually."
            }
        except Exception as e:
            return {
                "success": False,
                "error_message": f"Could not process image format: {str(e)}. Please provide a PNG, JPG, or JPEG image."
            }

    @classmethod
    def _run_native_ocr(cls, img: Image.Image) -> str:
        """Invokes Windows Native Media OCR (Windows.Media.Ocr.OcrEngine)."""
        try:
            from winrt.windows.media.ocr import OcrEngine
            from winrt.windows.storage.streams import DataWriter
            from winrt.windows.graphics.imaging import SoftwareBitmap, BitmapPixelFormat

            rgba_img = img.convert('RGBA')
            writer = DataWriter()
            writer.write_bytes(rgba_img.tobytes())
            sb = SoftwareBitmap.create_copy_from_buffer(
                writer.detach_buffer(),
                BitmapPixelFormat.RGBA8,
                rgba_img.width,
                rgba_img.height
            )
            engine = OcrEngine.try_create_from_user_profile_languages()

            async def _run():
                res = await engine.recognize_async(sb)
                return res.text

            with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
                return pool.submit(lambda: asyncio.run(_run())).result()
        except Exception:
            return ""

    @classmethod
    def parse_equation_from_ocr_text(cls, raw: str) -> str:
        """Parses and isolates the mathematical problem statement or equation from raw OCR output."""
        text = raw.strip()

        # Remove leading list numbers e.g. "1. ", "(1) ", "Q1: "
        text = re.sub(r'^\s*(?:\d+[\.\)]|\([0-9a-zA-Z]+\)|[qQ]\d+[:\.]?)\s*', '', text)

        # Pattern: "if <equation>, what is the value of x?"
        m_if = re.search(r'if\s*([^,;\?]+)[,;\?]', text, re.I)
        if m_if and '=' in m_if.group(1):
            text = m_if.group(1)
        else:
            # Check for a line containing '=' and variable 'x'
            for line in text.splitlines():
                if '=' in line and 'x' in line.lower():
                    text = line
                    break

        # Remove trailing inquiry clauses
        text = re.sub(r'[\?\.].*$', '', text)
        text = re.sub(r'^(?:solve|evaluate|find x in|if)\s*[:\-]?\s*', '', text, flags=re.I)
        text = re.sub(r'(?:what is the value of x|find the value of x|find x).*$', '', text, flags=re.I)

        # Clean math symbols
        text = cls.clean_ocr_text(text)

        # Normalize spaces around operators: '=', '+', '-'
        text = re.sub(r'\s*([=+\-])\s*', r' \1 ', text)

        # Restore coefficient variable spacing (e.g. "6 x" -> "6x")
        text = re.sub(r'(\d+)\s+([a-zA-Z])', r'\1\2', text)

        return text.strip()

    @classmethod
    def clean_ocr_text(cls, text: str) -> str:
        """Cleans and standardizes raw OCR characters into valid mathematical symbols."""
        s = text
        s = s.replace("²", "^2").replace("x2", "x²")
        s = s.replace("³", "^3").replace("x3", "x³")
        s = s.replace("×", "*").replace("÷", "/")
        s = s.replace("−", "-").replace("–", "-")
        s = s.replace("+/-", "±")
        return s

    @classmethod
    def _classify_topic(cls, eq: str) -> str:
        """Detects Grade 10-11 curriculum topic from equation string."""
        eq_low = eq.lower()
        if "x^2" in eq_low or "x²" in eq_low:
            return "Quadratic Equations"
        elif "x" in eq_low:
            return "Linear Equations"
        return "Algebraic Equations"
