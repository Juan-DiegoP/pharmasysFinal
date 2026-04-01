from models.base_model import BaseModel

class ClienteModel(BaseModel):

    def obtener(self, codigo):
        return self.db.execute("sp_ObtenerCliente", codigo)

    def insertar(self, values):
        return self.db.execute("sp_InsertarCliente", *values)

    def actualizar(self, values):
        return self.db.execute("sp_ActualizarCliente", *values)

    def eliminar(self, codigo):
        return self.db.execute("sp_EliminarCliente", codigo)

    def listar(self):
        return self.db.execute("sp_ListarClientes")