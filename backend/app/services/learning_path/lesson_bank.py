"""
Curriculum Lesson Content Bank — Component 1 (Aqeel M.I.M - IT23244016)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Provides textbook-grounded lessons aligned with the Sri Lankan National Curriculum for Grade 11 Mathematics
(Indices and Logarithms / දර්ශක හා ලඝුගණක).
Structured according to REQ-C1-06:
- Theory Explanation
- Laws & Formulas Summary
- Step-by-Step Worked Example with pedagogical breakdown
- Guided Practice Problem with progressive hints
- Quick Check / Re-assessment Quiz
"""
from typing import Dict, Any, Optional

LESSON_BANK: Dict[str, Dict[str, Any]] = {
    "10000000-0000-0000-0000-000000000001": {
        "concept_id": "10000000-0000-0000-0000-000000000001",
        "code": "MATH-G11-IND-01",
        "title": "Laws of Positive Integral Indices",
        "grade_level": 11,
        "textbook_ref": "Grade 11 Mathematics Part I, Chapter 3, Section 3.1",
        "estimated_duration_minutes": 15,
        "theory": (
            "An index (or exponent) indicates how many times a base number is multiplied by itself. "
            "For example, a^n denotes the product of n factors of a, where 'a' is the base and 'n' is the index. "
            "When multiplying terms with identical bases, exponents add together. When dividing, exponents subtract. "
            "Any non-zero real number raised to the zero power equals 1 (a^0 = 1, a != 0)."
        ),
        "formulas": [
            {"name": "Multiplication Law", "rule": "a^m * a^n = a^(m+n)"},
            {"name": "Division Law", "rule": "a^m / a^n = a^(m-n) (a != 0)"},
            {"name": "Power of a Power Law", "rule": "(a^m)^n = a^(m*n)"},
            {"name": "Power of a Product", "rule": "(a * b)^n = a^n * b^n"},
            {"name": "Power of a Quotient", "rule": "(a / b)^n = a^n / b^n (b != 0)"},
            {"name": "Zero Index Rule", "rule": "a^0 = 1 (a != 0)"}
        ],
        "worked_example": {
            "problem": "Simplify the algebraic expression: (3x^2 y^3)^2 * (2x y^4) / (6x^3 y^8)",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Expand the squared factor using power-of-a-power rule",
                    "working": "(3x^2 y^3)^2 = 3^2 * (x^2)^2 * (y^3)^2 = 9x^4 y^6"
                },
                {
                    "step_number": 2,
                    "description": "Multiply the numerator terms combining like bases",
                    "working": "9x^4 y^6 * 2x y^4 = (9 * 2) * (x^4 * x^1) * (y^6 * y^4) = 18x^(4+1) y^(6+4) = 18x^5 y^10"
                },
                {
                    "step_number": 3,
                    "description": "Divide by the denominator using index subtraction rule",
                    "working": "(18x^5 y^10) / (6x^3 y^8) = (18/6) * x^(5-3) * y^(10-8) = 3x^2 y^2"
                }
            ],
            "final_answer": "3x^2 y^2"
        },
        "guided_practice": {
            "problem": "Simplify: (4a^3 b^2)^2 / (8a^5 b)",
            "hint": "Square both coefficients and variables in the numerator first: 4^2 = 16, (a^3)^2 = a^6.",
            "solution": "16a^6 b^4 / 8a^5 b = 2a^(6-5) b^(4-1) = 2a b^3"
        },
        "quiz": {
            "question": "What is the simplified form of (2^4 * 2^3) / 2^5?",
            "options": ["2^2 (4)", "2^12", "2^7", "1"],
            "correct_index": 0,
            "explanation": "2^(4+3) = 2^7. Then 2^7 / 2^5 = 2^(7-5) = 2^2 = 4."
        }
    },

    "10000000-0000-0000-0000-000000000002": {
        "concept_id": "10000000-0000-0000-0000-000000000002",
        "code": "MATH-G11-IND-02",
        "title": "Fractional and Negative Indices",
        "grade_level": 11,
        "textbook_ref": "Grade 11 Mathematics Part I, Chapter 3, Section 3.2",
        "estimated_duration_minutes": 20,
        "theory": (
            "Negative indices define reciprocal powers: a^(-n) = 1 / a^n (a != 0). "
            "Fractional indices define radical roots: a^(1/n) = n-th root of a. "
            "More generally, a^(m/n) represents the m-th power of the n-th root of a, or the n-th root of a^m: "
            "a^(m/n) = (n-th root of a)^m = n-th root of (a^m)."
        ),
        "formulas": [
            {"name": "Negative Exponent Definition", "rule": "a^(-n) = 1 / (a^n)"},
            {"name": "Unit Fractional Exponent", "rule": "a^(1/n) = n-th root of a"},
            {"name": "General Fractional Exponent", "rule": "a^(m/n) = (n-th root of a)^m"}
        ],
        "worked_example": {
            "problem": "Evaluate the exact numerical value of: 32^(-3/5)",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Convert the negative index into reciprocal form",
                    "working": "32^(-3/5) = 1 / (32^(3/5))"
                },
                {
                    "step_number": 2,
                    "description": "Take the 5th root of 32 first",
                    "working": "32^(1/5) = 2 (since 2^5 = 32)"
                },
                {
                    "step_number": 3,
                    "description": "Raise the root to the power of 3",
                    "working": "2^3 = 8, therefore 1 / (32^(3/5)) = 1/8"
                }
            ],
            "final_answer": "1/8"
        },
        "guided_practice": {
            "problem": "Evaluate: 64^(2/3)",
            "hint": "Find the cube root of 64 first, then square the result.",
            "solution": "64^(1/3) = 4, then 4^2 = 16"
        },
        "quiz": {
            "question": "What is the value of 81^(-1/4)?",
            "options": ["1/3", "-3", "1/9", "3"],
            "correct_index": 0,
            "explanation": "81^(-1/4) = 1 / (81^(1/4)) = 1 / 3."
        }
    },

    "10000000-0000-0000-0000-000000000003": {
        "concept_id": "10000000-0000-0000-0000-000000000003",
        "code": "MATH-G11-IND-03",
        "title": "Scientific Notation (Standard Form)",
        "grade_level": 11,
        "textbook_ref": "Grade 11 Mathematics Part I, Chapter 3, Section 3.3",
        "estimated_duration_minutes": 15,
        "theory": (
            "Scientific notation expresses any positive decimal number in the standard form: A * 10^n, "
            "where 1 <= A < 10 and n is an integer. "
            "If the original number is >= 10, n is positive (count positions shifted left). "
            "If the original number is < 1, n is negative (count positions shifted right)."
        ),
        "formulas": [
            {"name": "Standard Form", "rule": "A * 10^n (1 <= A < 10, n in Z)"},
            {"name": "Multiplication in Standard Form", "rule": "(A * 10^m) * (B * 10^n) = (A * B) * 10^(m+n)"}
        ],
        "worked_example": {
            "problem": "Calculate: (4.2 * 10^6) * (3.0 * 10^-2) / (1.4 * 10^3) giving the answer in standard form",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Group decimal coefficients and powers of 10",
                    "working": "Coefficients: (4.2 * 3.0) / 1.4 = 12.6 / 1.4 = 9.0"
                },
                {
                    "step_number": 2,
                    "description": "Apply index laws to the base 10 powers",
                    "working": "Powers of 10: 10^(6 + (-2) - 3) = 10^(4 - 3) = 10^1"
                },
                {
                    "step_number": 3,
                    "description": "Combine and verify standard form constraint (1 <= 9.0 < 10)",
                    "working": "9.0 * 10^1 = 9.0 * 10"
                }
            ],
            "final_answer": "9.0 * 10^1 (or 90)"
        },
        "guided_practice": {
            "problem": "Write 0.000458 in scientific notation",
            "hint": "Move the decimal point 4 places to the right so the leading non-zero digit is 4.",
            "solution": "4.58 * 10^-4"
        },
        "quiz": {
            "question": "Express 75,000,000 in standard scientific notation:",
            "options": ["7.5 * 10^7", "75 * 10^6", "7.5 * 10^6", "0.75 * 10^8"],
            "correct_index": 0,
            "explanation": "Moving the decimal point 7 places left gives 7.5 * 10^7."
        }
    },

    "10000000-0000-0000-0000-000000000004": {
        "concept_id": "10000000-0000-0000-0000-000000000004",
        "code": "MATH-G11-LOG-01",
        "title": "Definition of Logarithm and Form Conversion",
        "grade_level": 11,
        "textbook_ref": "Grade 11 Mathematics Part I, Chapter 4, Section 4.1",
        "estimated_duration_minutes": 20,
        "theory": (
            "A logarithm answers the question: 'To what power must the base be raised to obtain this number?' "
            "Formal definition: If a^x = y (where a > 0, a != 1, and y > 0), then log_a(y) = x. "
            "The statement a^x = y is in Index Form; the equivalent statement log_a(y) = x is in Logarithmic Form."
        ),
        "formulas": [
            {"name": "Equivalence Definition", "rule": "a^x = y <=> log_a(y) = x"},
            {"name": "Base to Same Base Log", "rule": "log_a(a) = 1 (since a^1 = a)"},
            {"name": "Log of One", "rule": "log_a(1) = 0 (since a^0 = 1)"}
        ],
        "worked_example": {
            "problem": "Convert 2^6 = 64 into logarithmic form and solve for x: log_3(x) = 4",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Convert 2^6 = 64 using base=2, exponent=6, value=64",
                    "working": "log_2(64) = 6"
                },
                {
                    "step_number": 2,
                    "description": "Convert log_3(x) = 4 into index form to solve for x",
                    "working": "Base is 3, exponent is 4 => x = 3^4"
                },
                {
                    "step_number": 3,
                    "description": "Evaluate the power",
                    "working": "x = 3 * 3 * 3 * 3 = 81"
                }
            ],
            "final_answer": "log_2(64) = 6; x = 81"
        },
        "guided_practice": {
            "problem": "Find the value of: log_5(125)",
            "hint": "Ask: 5 raised to what power equals 125? 5^1=5, 5^2=25, 5^3=125.",
            "solution": "log_5(125) = 3 because 5^3 = 125"
        },
        "quiz": {
            "question": "If log_x(36) = 2, what is the value of x (x > 0)?",
            "options": ["6", "18", "72", "4"],
            "correct_index": 0,
            "explanation": "Convert to index form: x^2 = 36. Since x > 0, x = 6."
        }
    },

    "10000000-0000-0000-0000-000000000005": {
        "concept_id": "10000000-0000-0000-0000-000000000005",
        "code": "MATH-G11-LOG-02",
        "title": "Laws of Logarithms",
        "grade_level": 11,
        "textbook_ref": "Grade 11 Mathematics Part I, Chapter 4, Section 4.2",
        "estimated_duration_minutes": 25,
        "theory": (
            "Because logarithms represent exponents, the laws of exponents directly derive the laws of logarithms. "
            "1. Product Law: log_a(x * y) = log_a(x) + log_a(y). "
            "2. Quotient Law: log_a(x / y) = log_a(x) - log_a(y). "
            "3. Power Law: log_a(x^k) = k * log_a(x)."
        ),
        "formulas": [
            {"name": "Product Law", "rule": "log_a(x * y) = log_a(x) + log_a(y)"},
            {"name": "Quotient Law", "rule": "log_a(x / y) = log_a(x) - log_a(y)"},
            {"name": "Power Law", "rule": "log_a(x^k) = k * log_a(x)"}
        ],
        "worked_example": {
            "problem": "Given that log_10(2) = 0.3010 and log_10(3) = 0.4771, calculate log_10(18)",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Express 18 as prime factors of 2 and 3",
                    "working": "18 = 2 * 9 = 2 * 3^2"
                },
                {
                    "step_number": 2,
                    "description": "Apply product and power laws of logarithms",
                    "working": "log_10(18) = log_10(2 * 3^2) = log_10(2) + 2 * log_10(3)"
                },
                {
                    "step_number": 3,
                    "description": "Substitute known values and add",
                    "working": "0.3010 + 2 * (0.4771) = 0.3010 + 0.9542 = 1.2552"
                }
            ],
            "final_answer": "1.2552"
        },
        "guided_practice": {
            "problem": "Simplify into a single logarithmic term: 2 log_a(x) - 3 log_a(y) + log_a(z)",
            "hint": "Apply power law first: log_a(x^2) - log_a(y^3) + log_a(z), then combine products and quotients.",
            "solution": "log_a((x^2 * z) / y^3)"
        },
        "quiz": {
            "question": "Simplify: log_2(48) - log_2(3)",
            "options": ["4", "16", "2", "log_2(45)"],
            "correct_index": 0,
            "explanation": "log_2(48) - log_2(3) = log_2(48/3) = log_2(16) = 4 (since 2^4 = 16)."
        }
    },

    "10000000-0000-0000-0000-000000000006": {
        "concept_id": "10000000-0000-0000-0000-000000000006",
        "code": "MATH-G11-LOG-03",
        "title": "Common Logarithms (Base 10) & Numerical Computations",
        "grade_level": 11,
        "textbook_ref": "Grade 11 Mathematics Part I, Chapter 4, Section 4.3",
        "estimated_duration_minutes": 25,
        "theory": (
            "Logarithms to base 10 are called common logarithms. When written as log(N) without base, base 10 is understood. "
            "Any common logarithm comprises two parts: log(N) = Characteristic + Mantissa. "
            "The Characteristic is an integer determined by writing N in standard form: if N = A * 10^c, characteristic is c. "
            "The Mantissa is a positive decimal (< 1) read from logarithmic four-figure tables."
        ),
        "formulas": [
            {"name": "Structure of Common Log", "rule": "log_10(N) = c + m (c in Z, 0 <= m < 1)"},
            {"name": "Bar Notation for Negatives", "rule": "c = -1 is written as 1-bar (1̄.m)"}
        ],
        "worked_example": {
            "problem": "Determine the characteristic of: (a) 425.6, (b) 0.0384",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Express 425.6 in standard scientific form",
                    "working": "425.6 = 4.256 * 10^2 => Characteristic = 2"
                },
                {
                    "step_number": 2,
                    "description": "Express 0.0384 in standard scientific form",
                    "working": "0.0384 = 3.84 * 10^-2 => Characteristic = -2 (written as 2-bar)"
                }
            ],
            "final_answer": "(a) 2; (b) 2-bar (-2)"
        },
        "guided_practice": {
            "problem": "What is the characteristic of log_10(7.82)?",
            "hint": "7.82 is already between 1 and 10, so 7.82 = 7.82 * 10^0.",
            "solution": "0"
        },
        "quiz": {
            "question": "What is the characteristic of 0.00712?",
            "options": ["3-bar (-3)", "3", "2-bar (-2)", "-4"],
            "correct_index": 0,
            "explanation": "0.00712 = 7.12 * 10^-3, so characteristic is 3-bar (-3)."
        }
    },

    "10000000-0000-0000-0000-000000000007": {
        "concept_id": "10000000-0000-0000-0000-000000000007",
        "code": "MATH-G11-LOG-04",
        "title": "Logarithmic and Exponential Equations",
        "grade_level": 11,
        "textbook_ref": "Grade 11 Mathematics Part I, Chapter 4, Section 4.4",
        "estimated_duration_minutes": 25,
        "theory": (
            "Exponential equations contain the variable in the exponent. "
            "Case 1 (Common Base): If a^f(x) = a^g(x), then f(x) = g(x). "
            "Case 2 (Different Bases): Take logarithms of both sides and solve using linear equations. "
            "Logarithmic equations contain variables within log arguments. Combine terms into a single log and convert to index form."
        ),
        "formulas": [
            {"name": "Equal Base Rule", "rule": "If a^x = a^y, then x = y (a != 0, 1, -1)"},
            {"name": "Logarithmic Equation Reduction", "rule": "log_a(f(x)) = b <=> f(x) = a^b"}
        ],
        "worked_example": {
            "problem": "Solve for x: 4^(2x - 1) = 32",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Express both sides with a common base of 2",
                    "working": "4 = 2^2, so 4^(2x - 1) = (2^2)^(2x - 1) = 2^(4x - 2); 32 = 2^5"
                },
                {
                    "step_number": 2,
                    "description": "Equate the exponents since bases are identical",
                    "working": "4x - 2 = 5"
                },
                {
                    "step_number": 3,
                    "description": "Solve the linear equation for x",
                    "working": "4x = 7 => x = 7/4 = 1.75"
                }
            ],
            "final_answer": "x = 7/4 (1.75)"
        },
        "guided_practice": {
            "problem": "Solve for x: 3^(x + 2) = 81",
            "hint": "Express 81 as a power of 3: 81 = 3^4.",
            "solution": "3^(x + 2) = 3^4 => x + 2 = 4 => x = 2"
        },
        "quiz": {
            "question": "Solve for x: log_2(x) + log_2(x - 2) = 3",
            "options": ["4", "-2", "4 and -2", "8"],
            "correct_index": 0,
            "explanation": "log_2(x(x-2)) = 3 => x^2 - 2x = 2^3 = 8 => x^2 - 2x - 8 = 0 => (x-4)(x+2)=0. Since x > 2 for logarithms, x = 4."
        }
    },

    # =========================================================================
    # GRADE 10 CURRICULUM LESSONS: Quadratic Equations (වර්ගජ සමීකරණ)
    # Grounded in Sri Lankan Grade 10 National Mathematics Curriculum
    # =========================================================================

    "c1111111-1111-1111-1111-111111111111": {
        "concept_id": "c1111111-1111-1111-1111-111111111111",
        "code": "MATH-G10-QUAD-01",
        "title": "Solving Quadratic Equations by Factorization",
        "grade_level": 10,
        "textbook_ref": "Grade 10 Mathematics Part I, Chapter 11, Section 11.1",
        "estimated_duration_minutes": 20,
        "theory": (
            "A quadratic equation is an equality of the form ax^2 + bx + c = 0 (a != 0). When solved by factorization, "
            "we apply the fundamental Zero-Product Principle: if the product of two real expressions is zero (A * B = 0), "
            "then at least one factor must be zero (A = 0 or B = 0). Once ax^2 + bx + c is factored into (x - p)(x - q) = 0, "
            "we separate it into two simple linear equations x - p = 0 and x - q = 0 to obtain the roots x = p and x = q. "
            "Always ensure all terms are moved to the left side and equated to zero before factoring."
        ),
        "formulas": [
            {"name": "Zero-Product Principle", "rule": "If A * B = 0, then A = 0 or B = 0"},
            {"name": "Standard Equation Form", "rule": "ax^2 + bx + c = 0 (a != 0)"}
        ],
        "worked_example": {
            "problem": "Solve for x: x^2 + 5x + 6 = 0",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Confirm the equation is in standard form with zero on the right-hand side",
                    "working": "x^2 + 5x + 6 = 0 (Standard form satisfied)"
                },
                {
                    "step_number": 2,
                    "description": "Factor the quadratic trinomial into two linear binomials",
                    "working": "Find numbers multiplying to 6 and adding to 5: 2 and 3 => (x + 2)(x + 3) = 0"
                },
                {
                    "step_number": 3,
                    "description": "Apply Zero-Product Principle and solve for x",
                    "working": "x + 2 = 0 => x = -2; or x + 3 = 0 => x = -3"
                }
            ],
            "final_answer": "x = -2 or x = -3"
        },
        "guided_practice": {
            "problem": "Solve for x: x^2 - 4x - 21 = 0",
            "hint": "Find two integers multiplying to -21 and adding to -4 (they are -7 and +3).",
            "solution": "(x - 7)(x + 3) = 0 => x = 7 or x = -3"
        },
        "quiz": {
            "question": "What are the solutions to the equation x(x - 5) = 0?",
            "options": ["x = 0 or x = 5", "x = 5 only", "x = -5 or x = 0", "x = 25"],
            "correct_index": 0,
            "explanation": "Applying the zero-product rule: either x = 0 or x - 5 = 0 => x = 5. Solutions are x = 0 or x = 5."
        }
    },

    "c1111111-1111-1111-1111-111111111002": {
        "concept_id": "c1111111-1111-1111-1111-111111111002",
        "code": "MATH-G10-QUAD-02",
        "title": "Factoring and Solving by Splitting Middle Term",
        "grade_level": 10,
        "textbook_ref": "Grade 10 Mathematics Part I, Chapter 11, Section 11.2",
        "estimated_duration_minutes": 15,
        "theory": (
            "A quadratic expression in one variable is an algebraic expression of the form ax^2 + bx + c, "
            "where a, b, and c are real numbers and a != 0. Factoring a quadratic expression means rewriting it "
            "as the product of two linear factors: (x + p)(x + q). In this factorization, the sum of p and q equals b "
            "(p + q = b), and their product equals ac (p * q = ac). For expressions where a = 1, we find two integers "
            "whose product is c and whose sum is b. When the middle term is absent (b = 0) and c is negative, we apply "
            "the difference of two squares identity: a^2 - b^2 = (a - b)(a + b)."
        ),
        "formulas": [
            {"name": "Standard Quadratic Form", "rule": "ax^2 + bx + c (a != 0)"},
            {"name": "Middle-Term Splitting Rule", "rule": "Find p, q such that p + q = b and p * q = a * c"},
            {"name": "Difference of Two Squares", "rule": "a^2 - b^2 = (a - b)(a + b)"}
        ],
        "worked_example": {
            "problem": "Factorize the quadratic expression completely: x^2 + 7x + 12",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Identify coefficients a=1, b=7, c=12. Find two numbers multiplying to 12 and adding to 7.",
                    "working": "Factors of 12: (1,12), (2,6), (3,4). Notice 3 + 4 = 7 and 3 * 4 = 12."
                },
                {
                    "step_number": 2,
                    "description": "Split the middle term 7x into 3x + 4x",
                    "working": "x^2 + 7x + 12 = x^2 + 3x + 4x + 12"
                },
                {
                    "step_number": 3,
                    "description": "Group terms and extract common factors",
                    "working": "= x(x + 3) + 4(x + 3) = (x + 3)(x + 4)"
                }
            ],
            "final_answer": "(x + 3)(x + 4)"
        },
        "guided_practice": {
            "problem": "Factorize: 2x^2 + 5x + 3",
            "hint": "Here a * c = 2 * 3 = 6. Find two numbers that multiply to 6 and add to 5 (they are 2 and 3).",
            "solution": "2x^2 + 2x + 3x + 3 = 2x(x + 1) + 3(x + 1) = (2x + 3)(x + 1)"
        },
        "quiz": {
            "question": "What are the factors of x^2 - 9?",
            "options": ["(x - 3)(x + 3)", "(x - 9)(x + 1)", "(x - 3)^2", "(x + 9)(x - 1)"],
            "correct_index": 0,
            "explanation": "Using the difference of two squares identity a^2 - b^2 = (a - b)(a + b), x^2 - 3^2 = (x - 3)(x + 3)."
        }
    },

    "c1111111-1111-1111-1111-111111111003": {
        "concept_id": "c1111111-1111-1111-1111-111111111003",
        "code": "MATH-G10-QUAD-03",
        "title": "Solving by Completing the Square",
        "grade_level": 10,
        "textbook_ref": "Grade 10 Mathematics Part I, Chapter 11, Section 11.3",
        "estimated_duration_minutes": 25,
        "theory": (
            "Not every quadratic equation can be easily factored with integers. The method of completing the square "
            "transforms any quadratic equation into a perfect square format: (x + p)^2 = q, from which the solutions "
            "are extracted by taking the square root of both sides. For an equation x^2 + bx = -c, the term required to "
            "complete the square on the left is always (b / 2)^2. Adding (b / 2)^2 to both sides produces the perfect "
            "square trinomial (x + b/2)^2 on the left side."
        ),
        "formulas": [
            {"name": "Perfect Square Expansion", "rule": "(x + d)^2 = x^2 + 2dx + d^2"},
            {"name": "Completing Square Term", "rule": "Add (b / 2)^2 to both sides"},
            {"name": "Square Root Extraction", "rule": "x + b/2 = +- sqrt(d)"}
        ],
        "worked_example": {
            "problem": "Solve for x by completing the square: x^2 + 6x - 7 = 0",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Move the constant term to the right-hand side",
                    "working": "x^2 + 6x = 7"
                },
                {
                    "step_number": 2,
                    "description": "Calculate (b / 2)^2 and add it to both sides",
                    "working": "(6 / 2)^2 = 3^2 = 9. So: x^2 + 6x + 9 = 7 + 9 = 16"
                },
                {
                    "step_number": 3,
                    "description": "Rewrite left side as perfect square and take square root",
                    "working": "(x + 3)^2 = 16 => x + 3 = +- 4"
                },
                {
                    "step_number": 4,
                    "description": "Solve for x",
                    "working": "x = -3 + 4 = 1; x = -3 - 4 = -7"
                }
            ],
            "final_answer": "x = 1 or x = -7"
        },
        "guided_practice": {
            "problem": "What number must be added to x^2 - 10x to make it a perfect square trinomial?",
            "hint": "Divide the coefficient of x by 2 (-10 / 2 = -5) and square the result.",
            "solution": "(-10 / 2)^2 = (-5)^2 = 25"
        },
        "quiz": {
            "question": "Solve (x - 2)^2 = 25 for x.",
            "options": ["x = 7 or x = -3", "x = 7 only", "x = 3 or x = -7", "x = 27"],
            "correct_index": 0,
            "explanation": "Taking square root of both sides: x - 2 = +- 5. Thus x = 2 + 5 = 7 or x = 2 - 5 = -3."
        }
    },

    "c1111111-1111-1111-1111-111111111004": {
        "concept_id": "c1111111-1111-1111-1111-111111111004",
        "code": "MATH-G10-QUAD-04",
        "title": "The Quadratic Formula & Word Problems",
        "grade_level": 10,
        "textbook_ref": "Grade 10 Mathematics Part I, Chapter 11, Section 11.4",
        "estimated_duration_minutes": 25,
        "theory": (
            "The general quadratic formula gives the exact solutions for any quadratic equation ax^2 + bx + c = 0 (a != 0): "
            "x = (-b +- sqrt(b^2 - 4ac)) / (2a). The radicand b^2 - 4ac is called the discriminant (Delta). "
            "When Delta > 0, the equation has two distinct real roots; when Delta = 0, exactly one real root; and when Delta < 0, "
            "no real roots exist. Quadratic equations frequently arise in geometry to determine dimensions of areas, and in physics "
            "to calculate projectile trajectory and flight time."
        ),
        "formulas": [
            {"name": "Quadratic Formula", "rule": "x = (-b +- sqrt(b^2 - 4ac)) / (2a)"},
            {"name": "Discriminant (Delta)", "rule": "Delta = b^2 - 4ac"}
        ],
        "worked_example": {
            "problem": "Solve for x using the quadratic formula: 2x^2 + 5x - 3 = 0",
            "steps": [
                {
                    "step_number": 1,
                    "description": "Identify coefficients a, b, and c",
                    "working": "a = 2, b = 5, c = -3"
                },
                {
                    "step_number": 2,
                    "description": "Compute the discriminant Delta = b^2 - 4ac",
                    "working": "Delta = 5^2 - 4(2)(-3) = 25 + 24 = 49 (sqrt(49) = 7)"
                },
                {
                    "step_number": 3,
                    "description": "Substitute into the formula and evaluate both roots",
                    "working": "x = (-5 +- 7) / (2 * 2) => x = (-5 + 7)/4 = 2/4 = 0.5; x = (-5 - 7)/4 = -12/4 = -3"
                }
            ],
            "final_answer": "x = 0.5 or x = -3"
        },
        "guided_practice": {
            "problem": "A rectangular garden has length (x + 3) meters and width x meters. If the area is 40 m^2, find x.",
            "hint": "Area = length * width => x(x + 3) = 40 => x^2 + 3x - 40 = 0. Solve for positive x.",
            "solution": "x^2 + 3x - 40 = 0 => (x + 8)(x - 5) = 0. Since dimension must be positive, x = 5 meters."
        },
        "quiz": {
            "question": "What is the discriminant of the quadratic equation x^2 + 4x + 4 = 0?",
            "options": ["0 (one repeated root)", "16", "32", "-8"],
            "correct_index": 0,
            "explanation": "Delta = b^2 - 4ac = 4^2 - 4(1)(4) = 16 - 16 = 0. The equation has exactly one real repeated root (x = -2)."
        }
    }
}


def get_lesson_for_concept(concept_id: str) -> Optional[Dict[str, Any]]:
    """Retrieves structured curriculum lesson material for a concept node."""
    return LESSON_BANK.get(concept_id)
