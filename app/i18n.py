from flask import session, request

TRANSLATIONS = {
    "en": {
        "home": "Home",
        "about_us": "About Us",
        "our_vision": "Our Vision",
        "our_mission": "Our Mission",
        "services": "Services",
        "procurement": "Procurement",
        "training": "Training",
        "course_catalog": "Course Catalog",
        "registration": "Registration",
        "milwaukee": "Milwaukee",
        "products_catalog": "Products Catalog",
        "quote": "Quote",
        "buy": "Buy",
        "tool_rent": "Tool Rent",
        "safety": "Safety",
        "invoices_payments": "Invoices / Payments",
        "invoices": "Invoices",
        "credits": "Credits",
        "special_offer": "Special Offer",
        "support": "Support",
        "leave_message": "Leave Message",
        "faq": "FAQ",
        "contact_us": "Contact Us",
        "language": "Language",
        "signup": "Sign Up",
        "login": "Log In",
        "logout": "Log Out",
        "my_account": "My Account",
        "profile": "Profile",
        "page": "Page",
        "coming_soon": "This page is ready. Dynamic features will be added in the next steps."
    },
    "mn": {
        "home": "Нүүр",
        "about_us": "Бидний тухай",
        "our_vision": "Алсын хараа",
        "our_mission": "Эрхэм зорилго",
        "services": "Үйлчилгээ",
        "procurement": "Нийлүүлэлт",
        "training": "Сургалт",
        "course_catalog": "Сургалтын жагсаалт",
        "registration": "Бүртгэл",
        "milwaukee": "Milwaukee",
        "products_catalog": "Бүтээгдэхүүний каталог",
        "quote": "Үнийн санал",
        "buy": "Захиалга",
        "tool_rent": "Багаж түрээс",
        "safety": "Аюулгүй байдал",
        "invoices_payments": "Нэхэмжлэл / Төлбөр",
        "invoices": "Нэхэмжлэл",
        "credits": "Кредит",
        "special_offer": "Тусгай санал",
        "support": "Тусламж",
        "leave_message": "Мессеж үлдээх",
        "faq": "Түгээмэл асуулт",
        "contact_us": "Холбоо барих",
        "language": "Хэл",
        "signup": "Бүртгүүлэх",
        "login": "Нэвтрэх",
        "logout": "Гарах",
        "my_account": "Миний булан",
        "profile": "Профайл",
        "page": "Хуудас",
        "coming_soon": "Энэ хуудас бэлэн. Дараагийн алхмуудад динамик хэсгүүд нэмнэ."
    }
}

def get_lang():
    lang = session.get("lang")
    if lang in TRANSLATIONS:
        return lang
    # Default: browser preference -> en fallback
    accept = (request.accept_languages.best or "").lower()
    if accept.startswith("mn"):
        return "mn"
    return "en"

def t(key: str) -> str:
    lang = get_lang()
    return TRANSLATIONS.get(lang, TRANSLATIONS["en"]).get(key, key)
