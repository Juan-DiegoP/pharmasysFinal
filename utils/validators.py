import re

def solo_numeros(valor):
    return valor.isdigit()

def validar_email(email):
    return re.match(r"[^@]+@[^@]+\.[^@]+", email)

def texto_valido(texto):
    return 3 <= len(texto) <= 50