import sqlite3

conn = sqlite3.connect("greystone.db")
rows = conn.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()
print("Tables:", [r[0] for r in rows])
conn.close()
