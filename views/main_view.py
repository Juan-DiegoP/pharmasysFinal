import tkinter as tk
from tkinter import ttk
from views.medicamento_view import MedicamentoView
from views.proveedor_view import ProveedorView
from views.principio_view import PrincipioView
from views.cliente_view import ClienteView

class MainView(tk.Tk):

    def __init__(self, db):
        super().__init__()

        # 🎨 ESTILOS
        style = ttk.Style()
        style.theme_use('clam')

        style.configure("Treeview",
            background="#ffffff",
            foreground="black",
            rowheight=25,
            fieldbackground="#ffffff"
        )

        style.configure("Treeview.Heading",
            font=("Arial", 10, "bold")
        )

        # 🪟 VENTANA
        self.title("Sistema PharmaSys")
        self.geometry("1200x750")

        # 🔷 BARRA SUPERIOR
        top = tk.Frame(self, bg="#2c3e50", height=60)
        top.pack(fill="x")

        tk.Label(
            top,
            text="Sistema de Gestión PharmaSys",
            font=("Arial", 18, "bold"),
            fg="white",
            bg="#2c3e50"
        ).pack(pady=10)

        # 🔷 SUBTÍTULO
        sub = tk.Frame(self, bg="#34495e", height=30)
        sub.pack(fill="x")

        tk.Label(
            sub,
            text="Sistema MVC | Base de Datos conectada",
            fg="white",
            bg="#34495e",
            font=("Arial", 10)
        ).pack()

        # 📑 TABS
        notebook = ttk.Notebook(self)
        notebook.pack(expand=True, fill="both", padx=10, pady=10)

        tabs = [ttk.Frame(notebook) for _ in range(4)]
        names = ["Medicamentos", "Proveedores", "Principios", "Clientes"]

        for t, n in zip(tabs, names):
            notebook.add(t, text=n)

        # 📦 VIEWS
        MedicamentoView(tabs[0], db)
        ProveedorView(tabs[1], db)
        PrincipioView(tabs[2], db)
        ClienteView(tabs[3], db)

        # 🔻 FOOTER
        footer = tk.Frame(self, bg="#ecf0f1", height=25)
        footer.pack(fill="x", side="bottom")

        tk.Label(
            footer,
            text="Sistema MVC | Versión 1.0",
            bg="#ecf0f1"
        ).pack(side="right", padx=10)