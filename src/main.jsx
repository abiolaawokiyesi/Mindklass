import React from "react";
import ReactDOM from "react-dom/client";
import MindKlass, { InstallPrompt } from "./MindKlass.jsx";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <MindKlass />
    <InstallPrompt />
  </React.StrictMode>
);
