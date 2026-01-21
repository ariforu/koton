#search for stremlit connect to postgres
#GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sp_app;
from sqlalchemy import text
import streamlit as st
def insert_partner(name):
    conn = st.connection("postgresql")
    with conn.session as session:
        session.execute(text("INSERT INTO partners (name) VALUES (:name)"), {"name": name})
        session.commit()
def get_partners():
    conn = st.connection("postgresql")
    with conn.session as session:
        result = session.execute(text("SELECT * FROM partners"))
        return result.all()
def create_table():
    conn = st.connection("postgresql")
    with conn.session as session:
        session.execute(text("CREATE TABLE IF NOT EXISTS partners (name TEXT PRIMARY KEY)"))
        session.commit()
create_table()


st.title("Partner Management")
input_name = st.text_input("Partner Name")
if st.button("Add Partner"):
    try:
        insert_partner(input_name)
        st.success("Partner added successfully")
    except Exception as e:
        st.error("Failed to add partner")

st.table(get_partners())
