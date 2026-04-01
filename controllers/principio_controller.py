from controllers.base_controller import BaseController
from models.principio_model import PrincipioModel

class PrincipioController(BaseController):

    def __init__(self, db):
        self.model = PrincipioModel(db)

    def insertar(self, values):
        if not self.validar_vacios(values):
            return "Campos vacíos"
        self.model.insertar(values)
        return "ok"

    def buscar(self, codigo):
        if not codigo:
            return "Ingrese código"
        return self.model.obtener(codigo)

    def eliminar(self, codigo):
        if not codigo:
            return "Ingrese código"
        self.model.eliminar(codigo)
        return "ok"

    def listar(self):
        return self.model.listar()
    
    def actualizar(self, values):
        if not self.validar(values): return "Campos vacios"
        self.model.actualizar(values)
        return "ok"