from config.database import Database
from views.main_view import MainView

db = Database()
db.connect()

app = MainView(db)
app.mainloop()  