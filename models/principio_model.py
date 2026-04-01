from models.base_model import BaseModel

class PrincipioModel(BaseModel):

    def obtener(self, codigo):
        return self.db.execute("sp_ObtenerPrincipio", codigo)

    def insertar(self, values):
        return self.db.execute("sp_InsertarPrincipio", *values)

    def actualizar(self, values):
        return self.db.execute("sp_ActualizarPrincipio", *values)

    def eliminar(self, codigo):
        return self.db.execute("sp_EliminarPrincipio", codigo)

    def listar(self):
        return self.db.execute("sp_ListarPrincipios")