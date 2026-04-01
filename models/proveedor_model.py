from models.base_model import BaseModel

class ProveedorModel(BaseModel):

    def obtener(self, codigo):
        return self.db.execute("sp_ObtenerProveedor", codigo)

    def insertar(self, values):
        return self.db.execute("sp_InsertarProveedor", *values)

    def actualizar(self, values):
        return self.db.execute("sp_ActualizarProveedor", *values)

    def eliminar(self, codigo):
        return self.db.execute("sp_EliminarProveedor", codigo)

    def listar(self):
        return self.db.execute("sp_ListarProveedores")