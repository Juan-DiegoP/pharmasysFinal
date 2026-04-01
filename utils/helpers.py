from tabulate import tabulate

def tabla(results):
    texto = ""
    for headers, rows in results:
        texto += tabulate(rows, headers=headers, tablefmt="grid") + "\n\n"
    return texto