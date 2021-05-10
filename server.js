const express = require('express');
const path = require('path');
const app = express();

app.use(express.static(path.join(__dirname, './client-app/')));
app.use(express.static(path.join(__dirname, './build/contracts/')));
app.use(express.static(path.join(__dirname, './node_modules/')));

app.get('/', (req, res) => {
    res.sendFile('./client-app/index.html');
});

app.listen(8080, () => {
    console.log("Spinning on PORT => 8080");
});