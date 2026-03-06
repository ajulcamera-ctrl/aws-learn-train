import React, { useState, useEffect } from 'react';
import './App.css';

const API_BASE = 'http://localhost:8000'; // Change to deployed URL

function App() {
  const [workouts, setWorkouts] = useState([]);
  const [hikes, setHikes] = useState([]);
  const [activeTab, setActiveTab] = useState('workouts');

  useEffect(() => {
    fetchWorkouts();
    fetchHikes();
  }, []);

  const fetchWorkouts = async () => {
    const res = await fetch(`${API_BASE}/workouts/`);
    const data = await res.json();
    setWorkouts(data);
  };

  const fetchHikes = async () => {
    const res = await fetch(`${API_BASE}/hikes/`);
    const data = await res.json();
    setHikes(data);
  };

  const deleteWorkout = async (id) => {
    await fetch(`${API_BASE}/workouts/${id}`, { method: 'DELETE' });
    fetchWorkouts();
  };

  const deleteHike = async (id) => {
    await fetch(`${API_BASE}/hikes/${id}`, { method: 'DELETE' });
    fetchHikes();
  };

  return (
    <div className="App">
      <h1>Training & Hikes Tracker</h1>
      <div>
        <button onClick={() => setActiveTab('workouts')}>Workouts</button>
        <button onClick={() => setActiveTab('hikes')}>Hikes</button>
      </div>
      {activeTab === 'workouts' && (
        <div>
          <h2>Workouts</h2>
          <WorkoutForm onAdd={fetchWorkouts} />
          <ul>
            {workouts.map(w => (
              <li key={w.id}>
                {w.date} - {w.type} - {w.duration}min - {w.distance}km
                <button onClick={() => deleteWorkout(w.id)}>Delete</button>
              </li>
            ))}
          </ul>
        </div>
      )}
      {activeTab === 'hikes' && (
        <div>
          <h2>Hikes</h2>
          <HikeForm onAdd={fetchHikes} />
          <ul>
            {hikes.map(h => (
              <li key={h.id}>
                {h.date} - {h.location} - {h.distance}km - {h.elevation_gain}m
                <button onClick={() => deleteHike(h.id)}>Delete</button>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

function WorkoutForm({ onAdd }) {
  const [form, setForm] = useState({ id: '', date: '', type: '', duration: '', distance: '', notes: '' });

  const handleSubmit = async (e) => {
    e.preventDefault();
    await fetch(`${API_BASE}/workouts/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form)
    });
    onAdd();
    setForm({ id: '', date: '', type: '', duration: '', distance: '', notes: '' });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input placeholder="ID" value={form.id} onChange={e => setForm({...form, id: e.target.value})} required />
      <input type="date" value={form.date} onChange={e => setForm({...form, date: e.target.value})} required />
      <input placeholder="Type" value={form.type} onChange={e => setForm({...form, type: e.target.value})} required />
      <input type="number" placeholder="Duration (min)" value={form.duration} onChange={e => setForm({...form, duration: e.target.value})} required />
      <input type="number" step="0.1" placeholder="Distance (km)" value={form.distance} onChange={e => setForm({...form, distance: e.target.value})} required />
      <textarea placeholder="Notes" value={form.notes} onChange={e => setForm({...form, notes: e.target.value})} />
      <button type="submit">Add Workout</button>
    </form>
  );
}

function HikeForm({ onAdd }) {
  const [form, setForm] = useState({ id: '', date: '', location: '', duration: '', distance: '', elevation_gain: '', notes: '' });

  const handleSubmit = async (e) => {
    e.preventDefault();
    await fetch(`${API_BASE}/hikes/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form)
    });
    onAdd();
    setForm({ id: '', date: '', location: '', duration: '', distance: '', elevation_gain: '', notes: '' });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input placeholder="ID" value={form.id} onChange={e => setForm({...form, id: e.target.value})} required />
      <input type="date" value={form.date} onChange={e => setForm({...form, date: e.target.value})} required />
      <input placeholder="Location" value={form.location} onChange={e => setForm({...form, location: e.target.value})} required />
      <input type="number" placeholder="Duration (min)" value={form.duration} onChange={e => setForm({...form, duration: e.target.value})} required />
      <input type="number" step="0.1" placeholder="Distance (km)" value={form.distance} onChange={e => setForm({...form, distance: e.target.value})} required />
      <input type="number" placeholder="Elevation Gain (m)" value={form.elevation_gain} onChange={e => setForm({...form, elevation_gain: e.target.value})} required />
      <textarea placeholder="Notes" value={form.notes} onChange={e => setForm({...form, notes: e.target.value})} />
      <button type="submit">Add Hike</button>
    </form>
  );
}

export default App;