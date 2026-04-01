from reportlab.platypus import SimpleDocTemplate, Table

def exportar_pdf(headers, rows, nombre="reporte.pdf"):
    doc = SimpleDocTemplate(nombre)

    data = [headers] + rows
    table = Table(data)

    doc.build([table]) 