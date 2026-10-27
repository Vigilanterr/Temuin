import { Request, Response } from 'express';
import pool from '../config/db';

export const createPost = async (req: Request, res: Response): Promise<void> => {
    const { user_id, type, title, description, image_url, location } = req.body;
    try {
        if (!user_id || !type || !title || !description || !location) {
            res.status(400).json({ error: "Kolom wajib diisi" });
            return;
        }

        const result = await pool.query(
            'INSERT INTO posts (user_id, type, title, description, image_url, location) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
            [user_id, type, title, description, image_url || null, location]
        );

        res.status(201).json({
            message: "Post berhasil dibuat",
            post: result.rows[0]
        });
    } catch (error) {
        console.error('Error createPost:', error);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};

export const getPosts = async (req: Request, res: Response): Promise<void> => {
    try {
        const result = await pool.query(
            `SELECT p.*, u.name as author_name 
             FROM posts p 
             JOIN users u ON p.user_id = u.id 
             ORDER BY p.created_at DESC`
        );
        res.status(200).json({ data: result.rows });
    } catch (error) {
        console.error('Error getPosts:', error);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};

export const deletePost = async (req: Request, res: Response): Promise<void> => {
    const { id } = req.params;
    const { user_id } = req.body; 
    try {
        const result = await pool.query(
            'DELETE FROM posts WHERE id = $1 AND user_id = $2 RETURNING id',
            [id, user_id]
        );

        if (result.rows.length === 0) {
            res.status(403).json({ error: "Akses ditolak atau post tidak ditemukan" });
            return;
        }

        res.status(200).json({ message: "Post berhasil dihapus" });
    } catch (error) {
        console.error('Error deletePost:', error);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};