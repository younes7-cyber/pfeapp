require("dotenv").config();
const express = require("express");
const { MongoClient } = require("mongodb");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const PORT = process.env.PORT || 3000;
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

app.use(express.json());

const uri = process.env.MONGO_URI;
if (!uri) {
    console.error(" MongoDB URI manquant.");
    process.exit(1);
}

const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

async function connectDB() {
    try {
        await client.connect();
        console.log(" Connecté à MongoDB Atlas !");
    } catch (err) {
        console.error(" Erreur de connexion à MongoDB :", err);
    }
}
connectDB();

const db = client.db("testDB"); 
const collection = db.collection("messages");

app.get("/", (req, res) => {
    res.send(" API MongoDB en temps réel !");
});

app.get("/messages", async (req, res) => {
    try {
        const messages = await collection.find().toArray();
        res.json(messages);
    } catch (error) {
        res.status(500).json({ error: "Erreur de récupération" });
    }
});

app.post("/messages", async (req, res) => {
    try {
        const { message } = req.body;
        if (!message) return res.status(400).json({ error: "Message requis" });

        const newMessage = { message, createdAt: new Date() };
        await collection.insertOne(newMessage);
        io.emit("newMessage", newMessage); //  Envoi en temps réel

        res.json({ message: "Message ajouté !", data: newMessage });
    } catch (error) {
        res.status(500).json({ error: "Erreur d'ajout du message" });
    }
});

io.on("connection", (socket) => {
    console.log(" Un client est connecté !");
    socket.on("disconnect", () => console.log(" Client déconnecté"));
});

server.listen(PORT, () => {
    console.log(` Serveur WebSockets sur le port ${PORT}`);
});
