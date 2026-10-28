import swaggerJSDoc from 'swagger-jsdoc';

const swaggerOptions: swaggerJSDoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Temuin API Docs',
      version: '1.0.0',
      description: 'Dokumentasi REST API untuk platform Lost & Found',
    },
servers: [
  {
    url:
      process.env.NODE_ENV === 'production'
        ? 'https://domain-kamu.com'
        : 'http://localhost:3000',
    description:
      process.env.NODE_ENV === 'production'
        ? 'Production Server'
        : 'Development Server',
  },
],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  apis: ['./src/routes/*.ts'], 
};

export const swaggerSpec = swaggerJSDoc(swaggerOptions);