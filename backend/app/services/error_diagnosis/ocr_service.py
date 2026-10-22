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

            # 1. Perform Real Native OCR on center reticle region and full image
            raw_ocr_full = cls._run_native_ocr(img)
            
            # Reticle crop (aimed center area)
            try:
                crop_reticle = img.crop((int(width * 0.05), int(height * 0.20), int(width * 0.95), int(height * 0.85)))
                raw_ocr_reticle = cls._run_native_ocr(crop_reticle)
            except Exception:
                raw_ocr_reticle = ""

            # 2. Extract equations from both and pick best candidate
            eq_reticle = cls.parse_equation_from_ocr_text(raw_ocr_reticle) if raw_ocr_reticle else ""
            eq_full = cls.parse_equation_from_ocr_text(raw_ocr_full) if raw_ocr_full else ""

            # Prefer candidate with equals sign, math operators, or higher math density
            extracted_question = ""
            if eq_reticle and any(op in eq_reticle for op in ['=', '+', '-', '*', '/', '÷']):
                extracted_question = eq_reticle
            elif eq_full:
                extracted_question = eq_full
            elif eq_reticle:
                extracted_question = eq_reticle

            if extracted_question and extracted_question.strip():
                detected_topic = cls._classify_topic(extracted_question)
                return {
                    "success": True,
                    "extracted_question": extracted_question,
                    "raw_text": (raw_ocr_reticle or raw_ocr_full).strip(),
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

        # Standardize superscript & symbols
        text = text.replace("²", "^2").replace("³", "^3")
        text = text.replace("×", "*").replace("–", "-").replace("−", "-")

        # Remove question number prefix like "1. ", "2) ", "Q1: ", "(a) "
        text = re.sub(r'^\s*(?:\d+[\.\)]|\([0-9a-zA-Z]+\)|[qQ]\d+[:\.]?)\s*', '', text)

        # Remove "if" prefix if immediately preceding equation or numbers/variables: e.g. "if6x-4" or "if 6x-4"
        text = re.sub(r'\bif\s*(?=[0-9a-zA-Z])', '', text, flags=re.I)

        # Remove known conversational/UI prompt headers
        ui_patterns = [
            r'\bcan\s+you\s+solve\s+this[\?:]?',
            r'\bsolve\s+this[\?:]?',
            r'\bsolve\s+the\s+following[\?:]?',
            r'\bmathematics\s+(?:problem\s+solver|p\s+so\s+i\s+ver)\b',
            r'\bmathematical\s+question\s+input\b',
            r'\b(?:uestion|question)\s+statement(?:\s+equa[^\s]*)?',
            r'\b\d+\.\s*check\s+my\s+working(?:\s*\([^\)]*\))?',
            r'\bcheck\s+my\s+working(?:\s*\([^\)]*\))?',
            r'\bcapture\s+(?:question\s+)?camera\b',
            r'\bupload\s+photo\b',
            r'\buplo\S*photo\b',
            r'\bwhat\s+is\s+the\s+value\s+of\s+[a-zA-Z][\?:]?',
            r'\bvalue\s+of\s+[a-zA-Z][\?:]?',
            r'\bfind\s+(?:the\s+value\s+of\s+)?[a-zA-Z][\?:]?',
        ]
        cleaned = text
        for p in ui_patterns:
            cleaned = re.sub(p, ' ', cleaned, flags=re.I)

        # Search for equation patterns with '='
        eq_regex = r'([0-9a-zA-Z\(\)\^²³\+\-\*\/\÷\:\s]+=\s*[0-9a-zA-Z\(\)\^²³\+\-\*\/\÷\s\?\.,]*)'
        candidates = re.findall(eq_regex, cleaned)

        # Search for expressions without '='
        if not candidates:
            expr_regex = r'(\b\d+[\s\+\-\*\/\÷\(\)\^²³xX]+[\d\(\)\^²³xX\)]+)'
            candidates = re.findall(expr_regex, cleaned)

        if candidates:
            scored = []
            for cand in candidates:
                c = cand.strip()
                if not re.search(r'[\dxyzXYZ]', c):
                    continue
                math_chars = len(re.findall(r'[\d\+\-\*\/\÷\^\(\)\=xX]', c))
                total_len = max(len(c.replace(' ', '')), 1)
                density = math_chars / total_len
                bonus = 2.0 if '=' in c else 1.0
                if any(op in c for op in ['+', '-', '*', '/', '÷', '^', '(', ')']):
                    bonus += 1.0
                score = density * bonus * math_chars
                scored.append((score, c))

            if scored:
                scored.sort(key=lambda x: x[0], reverse=True)
                best = scored[0][1]

                if '=' in best:
                    lhs, rhs = best.split('=', 1)
                    # Find start of math in LHS (digits, variables, sign, or parenthesis)
                    m_lhs = re.search(r'([+\-]?\s*(?:\b\d+[a-zA-Z0-9\^²³]*|\b[a-zA-Z]\b|\()[0-9a-zA-Z\s\(\)\^²³\+\-\*\/\÷\.]*)$', lhs.strip())
                    clean_lhs = m_lhs.group(0).strip() if m_lhs else lhs.strip()

                    # Find math in RHS up to English text or list numbers
                    clean_rhs = rhs.strip()
                    clean_rhs = re.sub(r'\b\d+\.\s*.*$', '', clean_rhs)
                    clean_rhs = re.sub(r'\b[a-zA-Z]{2,}\b.*$', '', clean_rhs).strip()
                    clean_rhs = clean_rhs.rstrip(',;.')

                    if clean_rhs in ['', '?', 'x', 'X', '.']:
                        best = f"{clean_lhs} ="
                    else:
                        best = f"{clean_lhs} = {clean_rhs}"
                return best.strip()

        return cleaned.strip()

    @classmethod
    def clean_ocr_text(cls, text: str) -> str:
        """Cleans and standardizes raw OCR characters into valid mathematical symbols."""
        s = text
        s = s.replace("²", "^2").replace("x2", "x²")
        s = s.replace("³", "^3").replace("x3", "x³")
        s = s.replace("×", "*").replace("–", "-").replace("−", "-")
        s = s.replace("+/-", "±")
        return s

    @classmethod
    def _classify_topic(cls, eq: str) -> str:
        """Detects curriculum topic from equation string."""
        eq_low = eq.lower()
        if "x^2" in eq_low or "x²" in eq_low:
            return "Quadratic Equations"
        elif "x" in eq_low:
            return "Linear Equations"
        return "Order of Operations (BODMAS / Arithmetic)"
