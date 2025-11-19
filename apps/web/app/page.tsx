export default function Home() {
  return (
    <main style={{ padding: 24 }}>
      <h1>TeamFlow Web (Next.js)</h1>
      <p>Frontend inicial com Next.js (porta 5173).</p>
      <ul>
        <li>
          Gateway: <a href="http://localhost:3000/docs">http://localhost:3000/docs</a>
        </li>
        <li>
          Auth: <a href="http://localhost:3001/docs">http://localhost:3001/docs</a>
        </li>
      </ul>
    </main>
  );
}
