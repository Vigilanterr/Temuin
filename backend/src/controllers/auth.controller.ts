import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../config/db';

export const login = async (req: Request, res: Response): Promise<void> => {
    const { email, password } = req.body;
    try {
        if (!email || !password) {
            res.status(400).json({ error: "wajib di isi" });
            return;
        }

        const result = await pool.query('SELECT * FROM USERS WHERE email = $1', [email]);
        const user = result.rows[0];
        
        if (!user) {
            res.status(401).json({ error: "Ada yang salah dari inputan anda" });
            return;
        }

        const checkUser = await bcrypt.compare(password, user.password);
        if (!checkUser) {
            res.status(401).json({ error: "Ada yang salah" });
            return;
        }

        const token = jwt.sign(
            { id: user.id, email: user.email },
            process.env.JWT_SECRET as string,
            { expiresIn: '2d' }
        );

        res.status(200).json({
            message: "login berhasil",
            token,
            user: { id: user.id, email: user.email }
        });

    } catch (error) {
        console.error('Error saat login:', error);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};

export const register = async (req: Request, res: Response): Promise<void> => {
    const { email, name, password } = req.body;
    try {  
        if (!email || !password || !name) {
            res.status(400).json({ error: "Wajib di isi" });
            return;
        }

        const checkAvailable = await pool.query('SELECT * FROM users where email = $1', [email]);
        if (checkAvailable.rows.length) {
            res.status(400).json({ error: "sudah terdaftar" });
            return;
        }

        const hash = await bcrypt.genSalt(10);
        const hashedPass = await bcrypt.hash(password, hash);

        const hasil = await pool.query(
            'INSERT INTO users (name, email, password) values ($1, $2, $3) RETURNING id, email, name, created_at',
            [name, email, hashedPass]
        );
        
        res.status(201).json({
            message: 'berhasil regis',
            user: hasil.rows[0]
        });

    } catch (error) {
        console.log('error', error);
        res.status(500).json({ error: "terjadi kesalahan pada server" });
    }
};