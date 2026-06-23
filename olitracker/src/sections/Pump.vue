<template>
  <div class="pump-tracker-container">
    <header class="tracker-header">
      <h2>Pumping Tracker</h2>
      <p>Log your session times and yields</p>
    </header>

    <div class="session-timer-box">
      <div v-if="!isTimerRunning" class="timer-actions">
        <button type="button" class="btn-start-now" @click="startSessionNow">
          ⏱️ Start Session Now
        </button>
      </div>
      <div v-else class="timer-actions running">
        <div class="pulse-indicator">
          <span class="dot"></span> Pumping session in progress...
        </div>
        <button type="button" class="btn-stop-now" @click="stopSessionNow">
          🛑 Stop & Record Time
        </button>
      </div>
    </div>

    <div class="form-card">
      <div class="time-row">
        <div class="form-group">
          <label for="start-time">Start Time</label>
          <input 
            id="start-time" 
            type="datetime-local" 
            v-model="startTime" 
          />
        </div>
        <div class="form-group">
          <label for="end-time">End Time</label>
          <input 
            id="end-time" 
            type="datetime-local" 
            v-model="endTime" 
          />
        </div>
      </div>

      <hr class="divider" />

      <div class="amounts-row">
        <div class="form-group amount-box left-side">
          <label for="amount-left">Left Side (oz)</label>
          <div class="input-wrapper">
            <input 
              id="amount-left" 
              type="number" 
              v-model.number="amountLeft" 
              min="0" 
              step="0.25" 
              placeholder="0.0"
            />
            <span class="unit">oz</span>
          </div>
          <div class="quick-amounts">
            <button @click="amountLeft = (amountLeft || 0) + 0.5">+0.5</button>
            <button @click="amountLeft = (amountLeft || 0) + 1.0">+1.0</button>
            <button @click="amountLeft = 0" class="clear-btn">Clear</button>
          </div>
        </div>

        <div class="form-group amount-box right-side">
          <label for="amount-right">Right Side (oz)</label>
          <div class="input-wrapper">
            <input 
              id="amount-right" 
              type="number" 
              v-model.number="amountRight" 
              min="0" 
              step="0.25" 
              placeholder="0.0"
            />
            <span class="unit">oz</span>
          </div>
          <div class="quick-amounts">
            <button @click="amountRight = (amountRight || 0) + 0.5">+0.5</button>
            <button @click="amountRight = (amountRight || 0) + 1.0">+1.0</button>
            <button @click="amountRight = 0" class="clear-btn">Clear</button>
          </div>
        </div>
      </div>

      <div class="total-summary">
        Total Yield: <strong>{{ totalAmount }} oz</strong>
      </div>

      <div class="actions">
        <button type="button" class="btn-cancel" @click="resetForm">Clear Form</button>
        <button type="button" class="btn-submit" :disabled="!startTime || !endTime" @click="submitLog">
          Save Session
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

// State Management
const startTime = ref('');
const endTime = ref('');
const amountLeft = ref('');
const amountRight = ref('');
const isTimerRunning = ref(false);

// Helper function to get current localized ISO string for datetime-local inputs
const getLocalDateTimeString = () => {
  const now = new Date();
  const offset = now.getTimezoneOffset() * 60000;
  return new Date(now.getTime() - offset).toISOString().slice(0, 16);
};

// Quick Actions
const startSessionNow = () => {
  startTime.value = getLocalDateTimeString();
  endTime.value = '';
  isTimerRunning.value = true;
};

const stopSessionNow = () => {
  endTime.value = getLocalDateTimeString();
  isTimerRunning.value = false;
};

// Computed property for Total Ounces
const totalAmount = computed(() => {
  const left = parseFloat(amountLeft.value) || 0;
  const right = parseFloat(amountRight.value) || 0;
  return (left + right).toFixed(2);
});

// Reset Form State
const resetForm = () => {
  startTime.value = '';
  endTime.value = '';
  amountLeft.value = '';
  amountRight.value = '';
  isTimerRunning.value = false;
};

// Form Submission
const submitLog = () => {
  const payload = {
    field: 'feeding_pump',
    value: {
      start_time: startTime.value,
      end_time: endTime.value,
      left_oz: parseFloat(amountLeft.value) || 0,
      right_oz: parseFloat(amountRight.value) || 0,
      total_oz: parseFloat(totalAmount.value)
    },
    timestamp: new Date().toISOString()
  };

  console.log('Sending to Google Sheet:', payload);

  // TODO: Insert your axios / fetch request here to sync with backend
  
  resetForm();
};

</script>

<style scoped>
.pump-tracker-container {
  max-width: 500px;
  margin: 0 auto;
  padding: 16px;
  font-family: system-ui, -apple-system, sans-serif;
}

.tracker-header {
  text-align: center;
  margin-bottom: 20px;
}

.tracker-header h2 {
  margin: 0 0 4px 0;
  color: #2c3e50;
}

.tracker-header p {
  margin: 0;
  color: #7f8c8d;
  font-size: 0.9rem;
}

/* Timer Section */
.session-timer-box {
  margin-bottom: 16px;
}

.btn-start-now, .btn-stop-now {
  width: 100%;
  padding: 12px;
  border-radius: 12px;
  border: none;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.2s;
}

.btn-start-now {
  background-color: #e8f8f5;
  color: #117a65;
  border: 1px dashed #117a65;
}

.btn-stop-now {
  background-color: #fadbd8;
  color: #78281f;
  border: 1px dashed #78281f;
}

.timer-actions.running {
  display: flex;
  flex-direction: column;
  gap: 8px;
  background: #fdf2e9;
  padding: 12px;
  border-radius: 12px;
  border: 1px solid #e59866;
}

.pulse-indicator {
  font-size: 0.85rem;
  color: #d35400;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Pulsing Red Dot Animation */
.dot {
  width: 8px;
  height: 8px;
  background-color: #e74c3c;
  border-radius: 50%;
  display: inline-block;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0% { transform: scale(0.9); opacity: 1; }
  50% { transform: scale(1.2); opacity: 0.4; }
  100% { transform: scale(0.9); opacity: 1; }
}

/* Main Layout Card */
.form-card {
  background: #ffffff;
  border: 1px solid #eaeded;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.time-row, .amounts-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 16px;
}

.form-group label {
  font-size: 0.85rem;
  font-weight: 600;
  color: #34495e;
}

input[type="datetime-local"], 
input[type="number"] {
  padding: 10px;
  border: 1px solid #d5dbdb;
  border-radius: 8px;
  font-size: 0.95rem;
  font-family: inherit;
}

/* Ounce Inputs wrapper */
.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-wrapper input {
  width: 100%;
  padding-right: 35px;
}

.input-wrapper .unit {
  position: absolute;
  right: 12px;
  color: #bdc3c7;
  font-size: 0.9rem;
}

/* Side Specific Accent Coloring */
.left-side label { color: #2980b9; }
.right-side label { color: #8e44ad; }

/* Quick increments buttons */
.quick-amounts {
  display: flex;
  gap: 4px;
  margin-top: 4px;
}

.quick-amounts button {
  flex: 1;
  padding: 4px 2px;
  font-size: 0.75rem;
  background: #f2f4f4;
  border: 1px solid #d5dbdb;
  border-radius: 4px;
  cursor: pointer;
}

.quick-amounts button.clear-btn {
  background: #fcf3f2;
  color: #c0392b;
}

.divider {
  border: 0;
  height: 1px;
  background: #f2f4f4;
  margin: 8px 0 16px 0;
}

/* Yield Summary display box */
.total-summary {
  background: #ebf5fb;
  border-radius: 8px;
  padding: 12px;
  text-align: center;
  color: #2c3e50;
  font-size: 1.05rem;
  margin-bottom: 20px;
}

/* Layout Button Actions */
.actions {
  display: flex;
  justify-content: space-between;
  gap: 12px;
}

.actions button {
  flex: 1;
  padding: 12px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  border: none;
}

.btn-cancel {
  background: #f2f4f4;
  color: #7f8c8d;
}

.btn-submit {
  background: #3498db;
  color: white;
}

.btn-submit:disabled {
  background: #d5dbdb;
  color: #7f8c8d;
  cursor: not-allowed;
}
</style> 