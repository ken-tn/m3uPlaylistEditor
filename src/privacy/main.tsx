import React from 'react'
import ReactDOM from 'react-dom/client'
import App2 from './AppPrivacy.tsx'
import '../index.css'
import {
    createBrowserRouter,
    RouterProvider,
  } from "react-router-dom";
import Root from '../routes/root.tsx';

const router = createBrowserRouter([
    {
        path: "/privacy",
        element: <Root />,
        children: [
            {
                index: true,
                element: <App2 />,
            },
        ]
    },
], {basename: "/m3uPlaylistEditor"});

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
)
