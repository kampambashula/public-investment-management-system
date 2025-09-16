# Public Investment Management System (PIMS) – Zambia

An **open-source web application** to support the appraisal, tracking, and monitoring of public investment projects in line with **Zambia’s Public Investment Management Guidelines (2023)**.

---

## 🚀 Project Overview

This system aims to:

- Provide a **central project registry** for public investments.
- Enable **evidence-based appraisal** of proposed projects.
- Support **budgeting and monitoring** aligned with national planning frameworks.
- Improve **transparency, accountability, and efficiency** in public investment management.

---

## 🛠️ Tech Stack

### Backend

- **Django REST Framework (Python)** – API development
- **PostgreSQL** – relational database
- **JWT Authentication** – secure user access
- Planned: **Docker** + **Nginx/Gunicorn** for deployment

### Frontend

- **React (TypeScript)** – user interface
- **Material UI** – design system
- **React Router** – navigation
- Planned: **Redux Toolkit** for state management

---


### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate   # (Linux/macOS)
venv\Scripts\activate      # (Windows)

pip install -r requirements.txt
python manage.py migrate
python manage.py runserver

## Features (WIP)

 Project registry (CRUD)

 Project appraisal workflow

 Budget allocation module

 Monitoring & evaluation dashboards

 Role-based user access (Admin, Planner, Auditor, Public Viewer)

 API for integration with external systems

## Contributing

We welcome contributions!

Fork the repo & create a feature branch

Submit a Pull Request with clear description

Follow coding guidelines in /docs

## License

This project is licensed under the MIT License – free to use and modify.

# Acknowledgements

Built in line with Zambia’s Public Investment Management Guidelines (2023)

Inspired by open-source digital governance initiatives worldwide

# Contact

Maintainer: Kampamba Shula
Let’s collaborate to make public investment more transparent, efficient, and impactful.
