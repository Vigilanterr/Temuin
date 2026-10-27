import { Request, Response } from 'express';
import pool from '../config/db';

export const createComment = async (req: Request, res: Response): Promise<void> => {
    const { post_id, user_id, content } = req.body;
    try {
        if (!post_id || !user_id || !content) {
            res.status(400).json({ error: "Kolom wajib diisi" });
            return;
        }

        const result = await pool.query(
            'INSERT INTO comments (post_id, user_id, content) VALUES ($1, $2, $3) RETURNING *',
            [post_id, user_id, content]
        );

        res.status(201).json({
            message: "Komentar berhasil ditambahkan",
            comment: result.rows[0]
        });
    } catch (error) {
        console.error('Error createComment:', error);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};

export const getCommentsByPost = async (req: Request, res: Response): Promise<void> => {
    const { post_id } = req.params;
    try {
        const result = await pool.query(
            `SELECT c.*, u.name as author_name 
             FROM comments c 
             JOIN users u ON c.user_id = u.id 
             WHERE c.post_id = $1 
             ORDER BY c.created_at ASC`,
            [post_id]
        );
        res.status(200).json({ data: result.rows });
    } catch (error) {
        console.error('Error getComments:', error);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};