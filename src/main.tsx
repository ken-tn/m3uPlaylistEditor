import React from 'react'
import ReactDOM from 'react-dom/client'
import {
    createBrowserRouter,
    RouterProvider,
  } from "react-router-dom";
import Root from './routes/root.tsx';
import App from './App.tsx'
import PrivacyApp from './privacy/AppPrivacy.tsx';

const router = createBrowserRouter([
    {
        path: "/",
        element: <Root />,
        children: [
            {
                index: true,
                element: <App />,
            },
            {
                path: "privacy",
                element: <PrivacyApp />,
            }
        ]
    },
], {basename: "/m3uPlaylistEditor"});

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
)
