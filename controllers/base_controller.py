class BaseController:
    def validar_vacios(self, values):
        return all(str(v).strip() != "" for v in values)
    