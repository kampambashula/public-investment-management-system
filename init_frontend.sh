#!/bin/bash

# Exit if error
set -e

echo "🎨 Setting up React frontend (TypeScript + Material UI + Router)..."

# Create frontend folder
npx create-react-app frontend --template typescript
cd frontend

# Install dependencies
npm install @mui/material @emotion/react @emotion/styled @mui/icons-material axios react-router-dom @types/react-router-dom

# Create src/api/axios.ts
mkdir -p src/api
cat <<EOL > src/api/axios.ts
import axios from "axios";

const api = axios.create({
  baseURL: "http://localhost:8000/api", // Django backend API
});

export default api;
EOL

# Create src/components/Layout.tsx
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

# Dashboard
cat <<EOL > src/pages/Dashboard.tsx
import React from "react";
import { Typography } from "@mui/material";

const Dashboard: React.FC = () => {
  return <Typography variant="h4">Welcome to PIMS Dashboard</Typography>;
};

export default Dashboard;
EOL

# Projects
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

# Appraisal
cat <<EOL > src/pages/Appraisal.tsx
import React from "react";
import { Typography } from "@mui/material";

const Appraisal: React.FC = () => {
  return <Typography variant="h4">Project Appraisal Section</Typography>;
};

export default Appraisal;
EOL

# Monitoring
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

echo "✅ React frontend (TS + MUI + Router) created successfully!"
echo "👉 Next steps:"
echo "   cd frontend && npm start"
