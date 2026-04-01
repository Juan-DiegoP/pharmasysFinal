from controllers.base_controller import BaseController
from models.medicamento_model import MedicamentoModel

class MedicamentoController(BaseController):

    def __init__(self, db):
        self.model = MedicamentoModel(db)

    def insertar(self, values):
        return self.model.insertar(values)

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
        return self.model.actualizar(values)