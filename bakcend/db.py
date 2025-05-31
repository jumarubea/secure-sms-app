import sqlite3
import os

DATABASE = os.getenv('DATABASE', 'messages.db')

def get_db():
    if not DATABASE:
        raise ValueError("DATABASE environment variable not set.")
    return DATABASE

def init_db():
    with sqlite3.connect(get_db()) as conn:
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS messages (
                id TEXT PRIMARY KEY,
                sender TEXT,
                content TEXT,
                timestamp TEXT,
                status TEXT,
                is_verified INTEGER
            )
        """)
        conn.commit()

def store_message(message_id, sender, content, timestamp, status, is_verified):
    with sqlite3.connect(get_db()) as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO messages (id, sender, content, timestamp, status, is_verified)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (message_id, sender, content, timestamp, status, int(is_verified)))
        conn.commit()

def get_db_messages():
    with sqlite3.connect(get_db()) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM messages")
        rows = cursor.fetchall()
        return [
            {
                "id": row[0],
                "sender": row[1],
                "content": row[2],
                "timestamp": row[3],
                "status": row[4],
                "is_verified": bool(row[5])
            } for row in rows
        ]

def update_message(message_id, status=None, is_verified=None):
    with sqlite3.connect(get_db()) as conn:
        cursor = conn.cursor()
        updated = False
        if status is not None:
            cursor.execute("UPDATE messages SET status = ? WHERE id = ?", (status, message_id))
            updated = updated or cursor.rowcount > 0
        if is_verified is not None:
            cursor.execute("UPDATE messages SET is_verified = ? WHERE id = ?", (int(is_verified), message_id))
            updated = updated or cursor.rowcount > 0
        conn.commit()
        return updated

def delete_message(message_id):
    with sqlite3.connect(get_db()) as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM messages WHERE id = ?", (message_id,))
        conn.commit()
        return cursor.rowcount > 0

def get_message_by_id(message_id):
    with sqlite3.connect(get_db()) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM messages WHERE id = ?", (message_id,))
        row = cursor.fetchone()
        if row:
            return {
                "id": row[0],
                "sender": row[1],
                "content": row[2],
                "timestamp": row[3],
                "status": row[4],
                "is_verified": bool(row[5])
            }
        return None