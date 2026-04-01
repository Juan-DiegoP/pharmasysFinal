import tkinter as tk
from tkinter import ttk, messagebox
from controllers.medicamento_controller import MedicamentoController
from utils.export_excel import exportar_excel
from utils.export_pdf import exportar_pdf
from utils.validators import solo_numeros

class MedicamentoView:

    def __init__(self, root, db):

        self.controller = MedicamentoController(db)

        # =========================
        # CONTENEDOR PRINCIPAL
        # =========================
        main_frame = ttk.Frame(root)
        main_frame.pack(fill="both", expand=True)

        # =========================
        # IZQUIERDA (FORMULARIO)
        # =========================
        left_frame = ttk.Frame(main_frame, padding=20)
        left_frame.pack(side="left", fill="y")

        # =========================
        # DERECHA (TABLA)
        # =========================
        right_frame = ttk.Frame(main_frame)
        right_frame.pack(side="right", fill="both", expand=True)

        # =========================
        # CAMPOS
        # =========================
        fields = ['codigo','nombre_comercial','forma','presentacion','indicaciones','precio']
        self.entries = {}

        for i, field in enumerate(fields):

            ttk.Label(left_frame, text=field, width=18).grid(row=i, column=0, pady=5)

            if field == "forma":
                entry = ttk.Combobox(
                    left_frame,
                    values=["TABLETA","CAPSULA","JARABE","INYECTABLE","CREMA"],
                    state="readonly",
                    width=30
                )
            else:
                entry = ttk.Entry(left_frame, width=32)

            entry.grid(row=i, column=1, pady=5)
            self.entries[field] = entry

        # =========================
        # BOTONES
        # =========================
        btn = ttk.Frame(left_frame)
        btn.grid(row=len(fields), column=0, columnspan=2, pady=15)

        tk.Button(btn, text="Buscar", bg="orange", command=self.buscar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Insertar", bg="green", fg="white", command=self.insertar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Actualizar", bg="blue", fg="white", command=self.actualizar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Eliminar", bg="red", fg="white", command=self.eliminar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Listar", command=self.listar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Limpiar", command=self.limpiar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Excel", command=self.exportar_excel).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="PDF", command=self.exportar_pdf).pack(side=tk.LEFT, padx=3)

        # =========================
        # TABLA (TREEVIEW)
        # =========================
        self.tree = ttk.Treeview(right_frame)

        scroll_y = ttk.Scrollbar(right_frame, orient="vertical", command=self.tree.yview)
        scroll_x = ttk.Scrollbar(right_frame, orient="horizontal", command=self.tree.xview)

        self.tree.configure(yscrollcommand=scroll_y.set, xscrollcommand=scroll_x.set)

        self.tree.pack(side="left", fill="both", expand=True)
        scroll_y.pack(side="right", fill="y")
        scroll_x.pack(side="bottom", fill="x")

        # CLICK EN TABLA
        self.tree.bind("<<TreeviewSelect>>", self.seleccionar_fila)

    # =========================
    # FUNCIONES
    # =========================

    def mostrar_tabla(self, results):

        for item in self.tree.get_children():
            self.tree.delete(item)

        for headers, rows in results:

            self.tree["columns"] = headers
            self.tree["show"] = "headings"

            for h in headers:
                self.tree.heading(h, text=h)
                self.tree.column(h, width=120)

            for row in rows:
                self.tree.insert("", "end", values=row)

    def seleccionar_fila(self, event):
        item = self.tree.selection()

        if item:
            valores = self.tree.item(item)["values"]

            for i, key in enumerate(self.entries):
                self.entries[key].config(state="normal")  # 🔓 activar todo
                self.entries[key].delete(0, tk.END)
                self.entries[key].insert(0, valores[i])

            # 🔒 SOLO bloquear código
            self.entries['codigo'].config(state="disabled")

    def insertar(self):
        valores = [e.get() for e in self.entries.values()]
        
        if any(v.strip() == "" for v in valores):
            messagebox.showerror("Error", "Todos los campos son obligatorios")
            return
        
        codigo = self.entries['codigo'].get()
        if not solo_numeros(codigo):
            messagebox.showerror("Error", "El código debe ser numérico")
            return

        r = self.controller.insertar(valores)

        messagebox.showinfo("Resultado", "Insertado correctamente")
        self.listar()

    def buscar(self):
        codigo = self.entries['codigo'].get()

        if not codigo:
            messagebox.showerror("Error", "Ingrese código")
            return

        r = self.controller.buscar(codigo)

        if isinstance(r, str):
            messagebox.showerror("Error", r)
        elif r:
            self.mostrar_tabla(r)

    def actualizar(self):
        valores = [e.get() for e in self.entries.values()]

        if any(v.strip() == "" for v in valores):
            messagebox.showerror("Error", "Todos los campos son obligatorios")
            return
        
        r = self.controller.actualizar(valores)

        messagebox.showinfo("Resultado", "Actualizado correctamente")
        self.listar()

    def eliminar(self):
        codigo = self.entries['codigo'].get()

        if not codigo:
            messagebox.showerror("Error", "Ingrese código")
            return
        
        if not messagebox.askyesno("Confirmar", "¿Eliminar registro?"):
            return

        r = self.controller.eliminar(codigo)

        messagebox.showinfo("Resultado", "Eliminado correctamente")
        self.listar()

    def listar(self):
        r = self.controller.listar()

        if r:
            self.mostrar_tabla(r)

    def limpiar(self):
        for e in self.entries.values():
            e.config(state="normal")  # 🔓 activar todo

            if isinstance(e, ttk.Combobox):
                e.set("")
            else:
                e.delete(0, tk.END)

    def exportar_excel(self):

        res = self.controller.listar()

        if res:
            headers, rows = res[0]
            exportar_excel(headers, rows, "medicamentos.xlsx")
            messagebox.showinfo("Ok", "Exportado a medicamentos.xlsx")

    def exportar_pdf(self):

        res = self.controller.listar()

        if res:
            headers, rows = res[0]
            exportar_pdf(headers, rows, "medicamentos.pdf")
            messagebox.showinfo("Ok", "Exportado a medicamentos.pdf")