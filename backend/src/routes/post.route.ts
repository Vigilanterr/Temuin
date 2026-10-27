import { Router } from 'express';
import { createPost, getPosts, deletePost } from '../controllers/post.controller';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Posts
 *   description: API untuk manajemen laporan kehilangan dan temuan barang
 */

/**
 * @swagger
 * /api/posts:
 *   post:
 *     summary: Membuat postingan baru (Lost / Found)
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - user_id
 *               - type
 *               - title
 *               - description
 *               - location
 *             properties:
 *               user_id:
 *                 type: integer
 *                 description: ID pengguna pembuat post (sementara dikirim via body)
 *               type:
 *                 type: string
 *                 enum: [LOST, FOUND]
 *                 description: Kategori laporan
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               location:
 *                 type: string
 *               image_url:
 *                 type: string
 *                 nullable: true
 *     responses:
 *       201:
 *         description: Post berhasil dibuat
 *       400:
 *         description: Kolom wajib belum diisi
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.post('/posts', createPost);

/**
 * @swagger
 * /api/posts:
 *   get:
 *     summary: Mengambil semua daftar postingan
 *     tags: [Posts]
 *     responses:
 *       200:
 *         description: Berhasil mengambil data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.get('/posts', getPosts);

/**
 * @swagger
 * /api/posts/{id}:
 *   delete:
 *     summary: Menghapus postingan berdasarkan ID
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID dari post yang akan dihapus
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - user_id
 *             properties:
 *               user_id:
 *                 type: integer
 *                 description: ID pengguna untuk validasi kepemilikan
 *     responses:
 *       200:
 *         description: Post berhasil dihapus
 *       403:
 *         description: Akses ditolak atau post tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.delete('/posts/:id', deletePost);

export default router;