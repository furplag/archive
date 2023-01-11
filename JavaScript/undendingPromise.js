/**
 * Unbending Promise is useful for retrying an operation that may sometimes fail for transient reasons .
 * it can be used to stop the retry loop whenever you want and exit the loop gracefully before the limit is reached . 
 * this can be achieved by setting the 'abort' parameter to true .
 *
 * @function unbendingPromise
 * @param {Function} fn - a function to retry, it should return a promise that resolves to a boolean indicating success or failure .
 * @param {string} [beacon] - an optional identifier to identify the process being retried
 * @param {number} [limit=100] - the maximum number of attempts to retry the function before it is rejected
 * @param {number} [delay=100] - the delay in milliseconds between retries
 * @param {boolean} [abort=false] - a flag that when set to true, will cause the promise to reject immediately .
 * 
 * @returns {Promise} - a promise that will resolve when the provided function returns true . the promise will retry with a delay 
 * if the provided function returns false, and it will be rejected if the limit is reached or the abort flag is true .
 */
function unbendingPromise(fn = () => Promise.resolve(true), beacon, limit = 100, delay = 100, abort = false) {
  let counter = limit;
  const attempt = (resolve, reject) => {
    if (counter === 0 || abort) {
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
