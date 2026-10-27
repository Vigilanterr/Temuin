import { Router } from 'express';
import { createComment, getCommentsByPost } from '../controllers/comment.controller';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Comments
 *   description: API untuk komentar pada postingan
 */

/**
 * @swagger
 * /api/comments:
 *   post:
 *     summary: Menambahkan komentar pada suatu postingan
 *     tags: [Comments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - post_id
 *               - user_id
 *               - content
 *             properties:
 *               post_id:
 *                 type: integer
 *               user_id:
 *                 type: integer
 *               content:
 *                 type: string
 *     responses:
 *       201:
 *         description: Komentar berhasil ditambahkan
 *       400:
 *         description: Kolom wajib belum diisi
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.post('/comments', createComment);

/**
 * @swagger
 * /api/comments/post/{post_id}:
 *   get:
 *     summary: Mengambil semua komentar dari postingan tertentu
 *     tags: [Comments]
 *     parameters:
 *       - in: path
 *         name: post_id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID post yang ingin dilihat komentarnya
 *     responses:
 *       200:
 *         description: Berhasil mengambil daftar komentar
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.get('/comments/post/:post_id', getCommentsByPost);

export default router;