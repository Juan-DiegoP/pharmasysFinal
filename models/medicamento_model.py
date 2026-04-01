from models.base_model import BaseModel

class MedicamentoModel(BaseModel):

    def obtener(self, codigo):
        return self.db.execute("sp_ObtenerMedicamento", codigo)

    def insertar(self, values):
        return self.db.execute("sp_InsertarMedicamento", *values)

    def actualizar(self, values):
        return self.db.execute("sp_ActualizarMedicamento", *values)

    def eliminar(self, codigo):
        return self.db.execute("sp_EliminarMedicamento", codigo)

    def listar(self):
        return self.db.execute("sp_ListarMedicamentos")