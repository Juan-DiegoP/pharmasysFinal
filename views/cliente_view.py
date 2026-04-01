import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from controllers.cliente_controller import ClienteController
from utils.export_excel import exportar_excel
from utils.export_pdf import exportar_pdf
from utils.validators import validar_email, solo_numeros
from tkcalendar import DateEntry
from PIL import Image, ImageTk
import os
import shutil, os


class ClienteView:

    def __init__(self, root, db):

        self.controller = ClienteController(db)
        self.ruta_imagen = None
        self.img_tk = None

        main_frame = ttk.Frame(root)
        main_frame.pack(fill="both", expand=True)

        left_frame = ttk.Frame(main_frame, padding=20)
        left_frame.pack(side="left", fill="y")

        right_frame = ttk.Frame(main_frame)
        right_frame.pack(side="right", fill="both", expand=True)

        fields = ['codigo','razon_social','contacto','correo','calificacion']
        self.entries = {}

        for i, field in enumerate(fields):

            ttk.Label(left_frame, text=field, width=18).grid(row=i, column=0, pady=5)

            if field == "calificacion":
                entry = ttk.Combobox(left_frame, values=["APROBADO","PENDIENTE"], state="readonly", width=30)
            else:
                entry = ttk.Entry(left_frame, width=32)

            entry.grid(row=i, column=1, pady=5)
            self.entries[field] = entry

        # 📅 FECHA
        ttk.Label(left_frame, text="fecha_registro").grid(row=6, column=0, pady=5)
        self.fecha = DateEntry(left_frame, width=30, date_pattern='yyyy-mm-dd')
        self.fecha.grid(row=6, column=1, pady=5)

        # 🖼 IMAGEN
        ttk.Label(left_frame, text="Imagen").grid(row=7, column=0, pady=5)

        img_frame = tk.Frame(left_frame, width=150, height=150, relief="solid", bd=1)
        img_frame.grid(row=7, column=1, pady=5)
        img_frame.pack_propagate(False)

        self.lbl_imagen = ttk.Label(img_frame, text="Sin imagen", anchor="center")
        self.lbl_imagen.pack(fill="both", expand=True)

        btn_img = ttk.Frame(left_frame)
        btn_img.grid(row=8, column=1)

        tk.Button(btn_img, text="Seleccionar", command=self.cargar_imagen).pack(side=tk.LEFT)
        tk.Button(btn_img, text="Limpiar", command=self.limpiar_imagen).pack(side=tk.LEFT)

        # BOTONES
        btn = ttk.Frame(left_frame)
        btn.grid(row=9, column=0, columnspan=2, pady=15)

        tk.Button(btn, text="Buscar", bg="orange", command=self.buscar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Insertar", bg="green", fg="white", command=self.insertar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Actualizar", bg="blue", fg="white", command=self.actualizar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Eliminar", bg="red", fg="white", command=self.eliminar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Listar", command=self.listar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Limpiar", command=self.limpiar).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="Excel", command=self.exportar_excel).pack(side=tk.LEFT, padx=3)
        tk.Button(btn, text="PDF", command=self.exportar_pdf).pack(side=tk.LEFT, padx=3)

        # TABLA
        self.tree = ttk.Treeview(right_frame)

        scroll_y = ttk.Scrollbar(right_frame, orient="vertical", command=self.tree.yview)
        scroll_x = ttk.Scrollbar(right_frame, orient="horizontal", command=self.tree.xview)

        self.tree.configure(yscrollcommand=scroll_y.set, xscrollcommand=scroll_x.set)

        self.tree.pack(side="left", fill="both", expand=True)
        scroll_y.pack(side="right", fill="y")
        scroll_x.pack(side="bottom", fill="x")

        self.tree.bind("<<TreeviewSelect>>", self.seleccionar_fila)

    # =========================
    # IMAGEN
    # =========================

    def cargar_imagen(self):
        ruta = filedialog.askopenfilename(
            filetypes=[("Imagenes", "*.png *.jpg *.jpeg *.gif")]
        )

        if ruta:
            self.ruta_imagen = ruta

            img = Image.open(ruta)
            img = img.resize((150,150), Image.LANCZOS)
            self.img_tk = ImageTk.PhotoImage(img)

            self.lbl_imagen.config(image=self.img_tk, text="")

    def limpiar_imagen(self):
        self.ruta_imagen = None
        self.lbl_imagen.config(image="", text="Sin imagen")

    # =========================
    # TABLA
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
                self.entries[key].config(state="normal")
                self.entries[key].delete(0, tk.END)
                self.entries[key].insert(0, valores[i])
            self.entries['codigo'].config(state="disabled")

            # Cargar imagen
            nombre_imagen = valores[-1]  # último campo
            if nombre_imagen and os.path.exists(f"assets/{nombre_imagen}"):
                img = Image.open(f"assets/{nombre_imagen}")
                img = img.resize((150, 150), Image.LANCZOS)
                self.img_tk = ImageTk.PhotoImage(img)
                self.lbl_imagen.config(image=self.img_tk, text="")
            else:
                self.limpiar_imagen()

            # 🔒 SOLO bloquear código
            self.entries['codigo'].config(state="disabled")

    def insertar(self):
        valores = [e.get() for e in self.entries.values()]

        # Validaciones PRIMERO
        if any(v.strip() == "" for v in valores):
            messagebox.showerror("Error", "Todos los campos son obligatorios")
            return
    
        codigo = self.entries['codigo'].get()
        if not solo_numeros(codigo):
            messagebox.showerror("Error", "El código debe ser numérico")
            return

        # Imagen
        nombre_imagen = ""
        if self.ruta_imagen:
            os.makedirs("assets", exist_ok=True)
            nombre_imagen = os.path.basename(self.ruta_imagen)
            shutil.copy(self.ruta_imagen, f"assets/{nombre_imagen}")

        valores.append(nombre_imagen)

        # Insert UNA sola vez
        r = self.controller.insertar(valores)

        if r is not None:
            messagebox.showinfo("Resultado", "Insertado correctamente")
            self.listar()
            self.limpiar()

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

        nombre_imagen = ""
        if self.ruta_imagen:
            os.makedirs("assets", exist_ok=True)
            nombre_imagen = os.path.basename(self.ruta_imagen)
            shutil.copy(self.ruta_imagen, f"assets/{nombre_imagen}") 

        valores.append(nombre_imagen)
        r = self.controller.insertar(valores)
        messagebox.showinfo("Resultado", "Insertado correctamente")
        self.listar()

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