import {createTheme, ThemeProvider} from "@mui/material/styles";
import { Outlet } from "react-router-dom";
import CssBaseline from '@mui/material/CssBaseline';
import {useMediaQuery} from "@mui/material";
import React from "react";
// import '@fontsource/roboto/300.css';
// import '@fontsource/roboto/400.css';
// import '@fontsource/roboto/500.css';
// import '@fontsource/roboto/700.css';
import { ColorModeContext } from "../contexts/ColorModeContext";

export default function Root() {
    const prefersDarkMode = useMediaQuery('(prefers-color-scheme: dark)');
    const [mode, setMode] = React.useState<'light' | 'dark'>(prefersDarkMode ? 'dark' : 'light');
    const colorMode = React.useMemo(
        () => ({
            toggleColorMode: () => {
                setMode((prevMode) => (prevMode === 'light' ? 'dark' : 'light'));
            },
        }),
        [],
    );

    const theme = React.useMemo(() =>
            createTheme({
                components: {
                    MuiCssBaseline: {
                        styleOverrides: {
                            body: {
                                scrollbarColor: "#6b6b6b #2b2b2b",
                                "&::-webkit-scrollbar, & *::-webkit-scrollbar": {
                                    backgroundColor: "inherit",
                                    width: '0.6em',
                                },
                                "&::-webkit-scrollbar-thumb, & *::-webkit-scrollbar-thumb": {
                                    backgroundColor: "#6b6b6b",
                                    borderRadius: 8,
                                    minHeight: 24,
                                },
                                "&::-webkit-scrollbar-thumb:focus, & *::-webkit-scrollbar-thumb:focus": {
                                    backgroundColor: "#959595",
                                },
                                "&::-webkit-scrollbar-thumb:active, & *::-webkit-scrollbar-thumb:active": {
                                    backgroundColor: "#959595",
                                },
                                "&::-webkit-scrollbar-thumb:hover, & *::-webkit-scrollbar-thumb:hover": {
                                    backgroundColor: "#959595",
                                },
                                "&::-webkit-scrollbar-corner, & *::-webkit-scrollbar-corner": {
                                    backgroundColor: "#2b2b2b",
                                },
                            },
                        },
                    },
                },
                palette: {
                    mode: mode,
                },
            }),
        [mode],
    )

    return (
        <>
            <ColorModeContext.Provider value={colorMode}>
                <ThemeProvider theme={theme}>
                    <CssBaseline enableColorScheme />
                    <div id="detail">
                        <Outlet />
                    </div>
                </ThemeProvider>
            </ColorModeContext.Provider>
        </>
    );
}
