#!/bin/bash

# Exit on error
set -e

# === CONFIG ===
PROJECT_NAME="pims"
APPS=("users" "projects" "appraisal" "monitoring")
PYTHON_VERSION="3.11"

echo "🚀 Setting up Full-Stack Public Investment Management System ($PROJECT_NAME)"

# Create project folder
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# ==========================
# BACKEND (Django + DRF)
# ==========================
echo "📦 Setting up Django backend..."
mkdir backend
cd backend

# Requirements
cat <<EOL > requirements.txt
Django>=4.2
djangorestframework
psycopg2-binary
django-cors-headers
drf-yasg
python-dotenv
gunicorn
EOL

pip install -r requirements.txt

# Start Django project
django-admin startproject $PROJECT_NAME .

# Create apps
for app in "${APPS[@]}"; do
    python manage.py startapp $app
done

# Enable CORS + DRF in settings.py
SETTINGS_FILE="$PROJECT_NAME/settings.py"
sed -i "s/INSTALLED_APPS = \[/INSTALLED_APPS = \[\n    'rest_framework',\n    'corsheaders',\n    'users',\n    'projects',\n    'appraisal',\n    'monitoring',/g" $SETTINGS_FILE
sed -i "s/MIDDLEWARE = \[/MIDDLEWARE = \[\n    'corsheaders.middleware.CorsMiddleware',/g" $SETTINGS_FILE
echo -e "\nCORS_ALLOW_ALL_ORIGINS = True\n" >> $SETTINGS_FILE

# Create Project model + API
cat <<EOL > projects/models.py
from django.db import models

class Project(models.Model):
    name = models.CharField(max_length=200)
    sector = models.CharField(max_length=100)
    budget = models.DecimalField(max_digits=15, decimal_places=2)
    start_date = models.DateField()
    end_date = models.DateField()

    def __str__(self):
        return self.name
EOL

mkdir -p projects/api
cat <<EOL > projects/api/serializers.py
from rest_framework import serializers
from projects.models import Project

class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = "__all__"
EOL

cat <<EOL > projects/api/views.py
from rest_framework import viewsets
from projects.models import Project
from .serializers import ProjectSerializer

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
EOL

cat <<EOL > projects/api/urls.py
from rest_framework.routers import DefaultRouter
from .views import ProjectViewSet

router = DefaultRouter()
router.register(r'projects', ProjectViewSet, basename='project')

urlpatterns = router.urls
EOL

# Hook API into main urls.py
cat <<EOL > $PROJECT_NAME/urls.py
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('projects.api.urls')),
]
EOL

# Migrate DB
python manage.py migrate

deactivate
cd ..

# ==========================
# FRONTEND (React + TS + MUI + Router)
# ==========================
echo "🎨 Setting up React frontend (TypeScript + MUI + Router)..."
npx create-react-app frontend --template typescript
cd frontend

npm install @mui/material @emotion/react @emotion/styled @mui/icons-material axios react-router-dom @types/react-router-dom

# Create src/api/axios.ts
mkdir -p src/api
cat <<EOL > src/api/axios.ts
import axios from "axios";

const api = axios.create({
  baseURL: "http://localhost:8000/api",
});

export default api;
EOL

# Create Layout
mkdir -p src/components
cat <<EOL > src/components/Layout.tsx
import React from "react";
import { AppBar, Toolbar, Typography, Drawer, List, ListItem, ListItemText, Box } from "@mui/material";
import { Link } from "react-router-dom";

const drawerWidth = 200;

const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <Box sx={{ display: "flex" }}>
      <Drawer
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          "& .MuiDrawer-paper": { width: drawerWidth, boxSizing: "border-box" },
        }}
        variant="permanent"
        anchor="left"
      >
        <Toolbar />
        <List>
          {[
            { text: "Dashboard", path: "/" },
            { text: "Projects", path: "/projects" },
            { text: "Appraisal", path: "/appraisal" },
            { text: "Monitoring", path: "/monitoring" },
          ].map((item) => (
            <ListItem button key={item.text} component={Link} to={item.path}>
              <ListItemText primary={item.text} />
            </ListItem>
          ))}
        </List>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
          <Toolbar>
            <Typography variant="h6" noWrap component="div">
              Public Investment Management System
            </Typography>
          </Toolbar>
        </AppBar>
        <Toolbar />
        {children}
      </Box>
    </Box>
  );
};

export default Layout;
EOL

# Create pages
mkdir -p src/pages

cat <<EOL > src/pages/Dashboard.tsx
import React from "react";
import { Typography } from "@mui/material";

const Dashboard: React.FC = () => {
  return <Typography variant="h4">Welcome to PIMS Dashboard</Typography>;
};

export default Dashboard;
EOL

cat <<EOL > src/pages/Projects.tsx
import React, { useEffect, useState } from "react";
import { Typography, List, ListItem } from "@mui/material";
import api from "../api/axios";

interface Project {
  id: number;
  name: string;
  sector: string;
  budget: string;
}

const Projects: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);

  useEffect(() => {
    api.get("/projects/").then((res) => setProjects(res.data));
  }, []);

  return (
    <div>
      <Typography variant="h4">Projects</Typography>
      <List>
        {projects.map((p) => (
          <ListItem key={p.id}>{p.name} ({p.sector}) - Budget: {p.budget}</ListItem>
        ))}
      </List>
    </div>
  );
};

export default Projects;
EOL

cat <<EOL > src/pages/Appraisal.tsx
import React from "react";
import { Typography } from "@mui/material";

const Appraisal: React.FC = () => {
  return <Typography variant="h4">Project Appraisal Section</Typography>;
};

export default Appraisal;
EOL

cat <<EOL > src/pages/Monitoring.tsx
import React from "react";
import { Typography } from "@mui/material";

const Monitoring: React.FC = () => {
  return <Typography variant="h4">Monitoring & Evaluation Section</Typography>;
};

export default Monitoring;
EOL

# Update App.tsx with routing
cat <<EOL > src/App.tsx
import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "./components/Layout";
import Dashboard from "./pages/Dashboard";
import Projects from "./pages/Projects";
import Appraisal from "./pages/Appraisal";
import Monitoring from "./pages/Monitoring";

const App: React.FC = () => {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/projects" element={<Projects />} />
          <Route path="/appraisal" element={<Appraisal />} />
          <Route path="/monitoring" element={<Monitoring />} />
        </Routes>
      </Layout>
    </Router>
  );
};

export default App;
EOL

cd ..

# ==========================
# ROOT FILES
# ==========================
echo "🛠 Creating env, Docker and README..."

cat <<EOL > .env
DEBUG=1
SECRET_KEY=changeme
SQL_ENGINE=django.db.backends.sqlite3
SQL_DATABASE=db.sqlite3
SQL_USER=
SQL_PASSWORD=
SQL_HOST=
SQL_PORT=
DATABASE=sqlite
EOL

# README
cat <<EOL > README.md
# Public Investment Management System (PIMS)

A **full-stack system** using:
- Django REST Framework (backend)
- React + TypeScript + Material UI + Router (frontend)

## Run locally
### Backend
\`\`\`bash
cd backend
source venv/bin/activate
python manage.py runserver
\`\`\`

### Frontend
\`\`\`bash
cd frontend
npm start
\`\`\`
EOL

echo "✅ Full-stack Django + React (TS, MUI, Router) project created!"
