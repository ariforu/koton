# Partner Management App

A minimal Databricks App using Streamlit to manage partners in Lakebase (PostgreSQL).

## Prerequisites

- Databricks workspace with **Apps** and **Lakebase** enabled
- Python 3.x installed (for local development)

## Files

| File | Description |
|------|-------------|
| `app.py` | Main Streamlit application |
| `app.yaml` | Databricks App configuration |
| `requirements.txt` | Python dependencies |
| `.streamlit/secrets.toml` | PostgreSQL credentials |

## Setup

### 1. Create a Lakebase Database

[Lakebase](https://www.databricks.com/blog/how-use-lakebase-transactional-data-layer-databricks-apps) is a fully managed PostgreSQL database integrated with Databricks.

1. Go to **Compute** → **OLTP Database (or Lakebase)**
2. Click **Create** and provide a name (e.g., `partner-db`)
3. Enable **Native user authentication**

> ⚠️ **Note**: Native PostgreSQL users are **not best practice** for production. Use service principal authentication via the app's client ID instead. We use native users here for demo simplicity.

### 2. Create Database User

Open **Lakebase Query UI** (database instance → **New Query**) and run:

```sql
CREATE USER sp_app WITH PASSWORD 'learn@dbx';
GRANT CREATE ON SCHEMA public TO sp_app;
```

> 💡 The app automatically creates the `partners` table on startup.

### 3. Configure Credentials

Edit `.streamlit/secrets.toml`:

```toml
[connections.postgresql]
dialect = "postgresql"
host = "your-lakebase-host.cloud.databricks.com"
port = "5432"
database = "databricks_postgres"
username = "sp_app"
password = "learn@dbx"
```

Replace `host` with your Lakebase endpoint (found in database details).

### 4. Local Development (Optional)

**Install Python 3:**
- **macOS**: `brew install python3`
- **Windows**: [python.org](https://www.python.org/downloads/) or `winget install Python.Python.3.11`
- **Linux**: `sudo apt install python3 python3-venv`

**Setup and run:**

```bash
python3 -m venv .venv
source .venv/bin/activate    # Windows: .venv\Scripts\activate
pip install -r requirements.txt
streamlit run app.py
```

### 5. Deploy to Databricks Apps

1. Go to **Workspace** → your user folder → **Import** all project files
2. Go to **Compute** → **Apps** → **Create App**
3. Set **Name** (e.g., `partner-management`) and **Source code path** to your folder
4. Click **Create** → **Deploy**
5. Wait for **Running** status, then click the **App URL**

**Troubleshooting:**
- View logs: App → **Logs** tab
- Update app: Make changes → click **Deploy**
- Secrets alternative: Use **Settings** → **Environment variables** instead of `secrets.toml`

## Features

- **Add Partner**: Form to enter partner name
- **Duplicate Prevention**: Primary key constraint rejects duplicates
- **Auto Table Creation**: Creates `partners` table on startup
- **Partner List**: Displays all partners

## Architecture

```
┌─────────────────┐      ┌─────────────────┐
│  Databricks App │ ───▶ │    Lakebase     │
│   (Streamlit)   │      │  (PostgreSQL)   │
└─────────────────┘      └─────────────────┘
```
