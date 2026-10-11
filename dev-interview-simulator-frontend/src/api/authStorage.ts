export const clearStoredAuth = () => {
  localStorage.removeItem('jwt_token');
  localStorage.removeItem('user');
  window.dispatchEvent(new Event('auth:logout'));
};
