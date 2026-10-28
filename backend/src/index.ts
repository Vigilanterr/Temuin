import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import authRoutes from './routes/auth.route';
import postRoutes from './routes/post.route';
import commentRoutes from './routes/comment.route';

import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';

dotenv.config();

const CSS_URL = "https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.1.0/swagger-ui.min.css";
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req:Request, res:Response) => 
    res.send("hi")
)
app.use('/api/auth', authRoutes); 
app.use('/api', postRoutes);      
app.use('/api', commentRoutes);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, { customCssUrl: CSS_URL }));


app.listen(PORT, () => {
    console.log('berhasil jlan');
});