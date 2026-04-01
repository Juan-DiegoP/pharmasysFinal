import mysql.connector
from tkinter import messagebox

class Database:

    def __init__(self):
        self.connection = None
        self.cursor = None

    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                host='localhost',
                user='root',
                password='',
                database='pharmasys'
            )
            self.cursor = self.connection.cursor()
        except mysql.connector.Error as e:
            messagebox.showerror("Error", str(e))

    def execute(self, sp, *args):
        try:
            self.cursor.callproc(sp, args)

            results = []
            for result in self.cursor.stored_results():
                rows = result.fetchall()
                if rows:
                    headers = [i[0] for i in result.description]
                    results.append((headers, rows))

            self.connection.commit()
            return results

        except mysql.connector.Error as e:
            self.connection.rollback()
            messagebox.showerror("Error", str(e))
            return None