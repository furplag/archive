/**
 * Unbending Promise
 * useful for retrying an operation that may sometimes fail for transient reasons, and you want 
 * to implement a mechanism to handle these failures automatically .
 * 
 * @param {Function} fn - a function to retry . it should return a promise that resolves to a boolean indicating success or failure .
 * @param {string} [beacon] - a string to identify the process being retried .
 * @param {number} [limit=100] - the number of times to retry the function .
 * @param {number} [delay=100] - the delay in milliseconds between retries .
 * 
 * @returns {Promise} a promise that resolves to the value returned by the function when it succeeds, or rejects with an error if 
 *                    the function fails to return a truthy value after the specified number of retries .
 */
function unbendingPromise(fn = () => Promise.resolve(true), beacon, limit = 100, delay = 100) {
  let counter = limit;
  const attempt = (resolve, reject) => {
    if (counter === 0) {
      return reject(`🚧 limit reached: ${beacon || 'a process'} (limit: ${limit}) .`);
    }
    fn().then(result => {
      if (result) {
          return resolve(result);
      } else {
          counter--;
          console.debug(`⌛ ${beacon || 'processing'}${limit < 0 ? '' : ` ( ${limit - counter} / ${limit} )`} ... `);
          return setTimeout(() => attempt(resolve, reject), delay);
      }
    }).catch(error => reject(error));
  };

  return new Promise(attempt);
}

export { unbendingPromise }
