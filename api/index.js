const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

const app = express();
const port = 3000;

const dbUrl = 'postgres://postgres:mypassword123!@localhost:5432/coding-challenge';
const pool = new Pool({ connectionString: dbUrl });

app.use(bodyParser.json());

app.post('/calendar/query', async (req, res) => {
  try {
    const { date, products, language, rating } = req.body;

    if (!date || !products || !language || !rating) {
      return res.status(400).send({ error: 'Missing fields in the request body.' });
    }

    const query = `
      SELECT
        s1.start_date,
        COUNT(*) AS available_count
      FROM available_slots s1
      JOIN sales_managers sm
        ON s1.sales_manager_id = sm.id
      WHERE $1 = ANY(sm.languages)
        AND sm.products @> $2
        AND $3 = ANY(sm.customer_ratings)
        AND s1.start_date::date = $4::date
      GROUP BY s1.start_date
      ORDER BY s1.start_date;
    `;

    const result = await pool.query(query, [language, products, rating, date]);

    if (result.rows.length === 0) {
      return res.status(200).json([]);
    }

    const formattedResponse = result.rows.map(row => ({
      start_date: row.start_date,
      available_count: parseInt(row.available_count, 10),
    }));

    res.status(200).json(formattedResponse);
  } catch (error) {
    res.status(500).send({ error: 'Internal server error.' });
  }
});

app.listen(port, () => {
  console.log(`The endpoint is executing at http://localhost:${port}/calendar/query`);
});
