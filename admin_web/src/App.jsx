import { useState, useEffect } from 'react';
import './index.css';

const API_URL = 'http://localhost:3000/api';

function App() {
  const [token, setToken] = useState(localStorage.getItem('adminToken'));
  const [user, setUser] = useState(JSON.parse(localStorage.getItem('adminUser')));
  const [loading, setLoading] = useState(false);

  // Login State
  const [loginNim, setLoginNim] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginError, setLoginError] = useState('');

  // Dashboard State
  const [users, setUsers] = useState([]);
  const [newWorker, setNewWorker] = useState({ nim: '', name: '', email: '', password: '', phone_number: '', role: 'worker' });
  const [createMsg, setCreateMsg] = useState('');

  useEffect(() => {
    if (token) {
      fetchUsers();
    }
  }, [token]);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setLoginError('');
    try {
      const res = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nim: loginNim, password: loginPassword })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Login failed');
      
      if (data.role !== 'admin') {
        throw new Error('Access denied. Admins only.');
      }

      setToken(data.token);
      setUser({ name: data.name, role: data.role });
      localStorage.setItem('adminToken', data.token);
      localStorage.setItem('adminUser', JSON.stringify({ name: data.name, role: data.role }));
    } catch (err) {
      setLoginError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
  };

  const fetchUsers = async () => {
    try {
      const res = await fetch(`${API_URL}/admin/users`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await res.json();
      if (res.ok) setUsers(data);
    } catch (err) {
      console.error(err);
    }
  };

  const handleCreateWorker = async (e) => {
    e.preventDefault();
    setCreateMsg('Creating...');
    try {
      const res = await fetch(`${API_URL}/admin/users`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(newWorker)
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error);
      
      setCreateMsg('User created successfully!');
      setNewWorker({ nim: '', name: '', email: '', password: '', phone_number: '', role: 'worker' });
      fetchUsers();
      setTimeout(() => setCreateMsg(''), 3000);
    } catch (err) {
      setCreateMsg(`Error: ${err.message}`);
    }
  };

  if (!token) {
    return (
      <div className="login-wrapper">
        <div className="card login-box">
          <div style={{textAlign: 'center', marginBottom: '2rem'}}>
            <div style={{fontSize: '3rem', marginBottom: '1rem'}}>🐝</div>
            <h1>Beehive Admin</h1>
            <p>Sign in to manage users and system.</p>
          </div>
          {loginError && <div style={{color: 'var(--danger)', marginBottom: '1rem', padding: '0.75rem', background: 'rgba(225,29,72,0.1)', borderRadius: '0.5rem'}}>{loginError}</div>}
          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label>Admin ID (NIM)</label>
              <input type="text" value={loginNim} onChange={e => setLoginNim(e.target.value)} required />
            </div>
            <div className="form-group">
              <label>Password</label>
              <input type="password" value={loginPassword} onChange={e => setLoginPassword(e.target.value)} required />
            </div>
            <button className="btn" style={{width: '100%'}} type="submit" disabled={loading}>
              {loading ? 'Authenticating...' : 'Sign In'}
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="container">
      <div className="header">
        <div>
          <h1>Admin Dashboard</h1>
          <p>Welcome back, {user?.name}</p>
        </div>
        <button className="btn btn-outline" onClick={handleLogout}>Logout</button>
      </div>

      <div className="dashboard-grid">
        <div className="card">
          <h2>System Users</h2>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>ID/NIM</th>
                  <th>Name</th>
                  <th>Role</th>
                  <th>Contact</th>
                </tr>
              </thead>
              <tbody>
                {users.map(u => (
                  <tr key={u.id}>
                    <td>
                      <div style={{fontWeight: 500, color: '#fff'}}>{u.nim}</div>
                      <div style={{fontSize: '0.75rem', color: 'var(--text-muted)'}}>#{u.id}</div>
                    </td>
                    <td>{u.name}</td>
                    <td>
                      <span className={`badge badge-${u.role}`}>{u.role}</span>
                    </td>
                    <td>
                      <div>{u.email}</div>
                      <div style={{fontSize: '0.875rem', color: 'var(--text-muted)'}}>{u.phone_number}</div>
                    </td>
                  </tr>
                ))}
                {users.length === 0 && (
                  <tr>
                    <td colSpan="4" style={{textAlign: 'center', padding: '2rem'}}>No users found.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        <div className="card">
          <h2>Create New Role</h2>
          <p style={{marginBottom: '1.5rem'}}>Add a new worker or admin to the system.</p>
          <form onSubmit={handleCreateWorker}>
            <div className="form-group">
              <label>Role</label>
              <select value={newWorker.role} onChange={e => setNewWorker({...newWorker, role: e.target.value})}>
                <option value="worker">Worker</option>
                <option value="admin">Admin</option>
              </select>
            </div>
            <div className="form-group">
              <label>Staff ID (NIM)</label>
              <input type="text" value={newWorker.nim} onChange={e => setNewWorker({...newWorker, nim: e.target.value})} required />
            </div>
            <div className="form-group">
              <label>Full Name</label>
              <input type="text" value={newWorker.name} onChange={e => setNewWorker({...newWorker, name: e.target.value})} required />
            </div>
            <div className="form-group">
              <label>Email Address</label>
              <input type="email" value={newWorker.email} onChange={e => setNewWorker({...newWorker, email: e.target.value})} required />
            </div>
            <div className="form-group">
              <label>Phone Number</label>
              <input type="text" value={newWorker.phone_number} onChange={e => setNewWorker({...newWorker, phone_number: e.target.value})} required />
            </div>
            <div className="form-group">
              <label>Initial Password</label>
              <input type="password" value={newWorker.password} onChange={e => setNewWorker({...newWorker, password: e.target.value})} required />
            </div>
            <button className="btn" style={{width: '100%'}} type="submit">Create User</button>
            {createMsg && <div style={{marginTop: '1rem', textAlign: 'center', color: createMsg.includes('Error') ? 'var(--danger)' : 'var(--success)'}}>{createMsg}</div>}
          </form>
        </div>
      </div>
    </div>
  );
}

export default App;
