from openpyxl import Workbook

def exportar_excel(headers, rows, nombre="reporte.xlsx"):
    wb = Workbook()
    ws = wb.active

    ws.append(headers)

    for row in rows:
        ws.append(row)

    wb.save(nombre)