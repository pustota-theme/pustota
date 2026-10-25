import React from 'react'


const Component = () =>
  <>
    <div>Something 1</div>
    <div>Something 2</div>
  </>


export const Main = () =>
  <div>
    <Component a="text" />
    <Component b={1} />
  </div>


export class MyClassComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0,
    }
  }
}

import { useState, useEffect, useMemo, useRef, useCallback } from 'react'
import * as Icons from './icons'
import styles from './main.module.css' with { type: 'css' }
export { Component as Fragmented }

const SIZES = Object.freeze({ small: 0x10, large: 0b1_0000_0000 })
const formatter = new Intl.NumberFormat('en-US', { maximumFractionDigits: 2 })
const slugPattern = /^(?<prefix>[a-z]+)-(?<id>\d+)$/i

const Forms = {
  Input: ({ label, ...rest }) => (
    <label className={styles.label}>
      {label}
      <input {...rest} />
    </label>
  ),
  Select: ({ options = [], value, onChange }) => (
    <select value={value} onChange={(event) => onChange?.(event.target.value)}>
      {options.map(({ id, name }, index) => (
        <option key={id ?? index} value={id}>{name}</option>
      ))}
    </select>
  ),
}

function useDebounced(value, delay = 300) {
  const [debounced, setDebounced] = useState(value)
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])
  return debounced
}

export function Dashboard({ items = [], title = 'Dashboard', children, ...props }) {
  const [query, setQuery] = useState('')
  const [selected, setSelected] = useState(null)
  const listRef = useRef(null)
  const debouncedQuery = useDebounced(query)

  const filtered = useMemo(
    () => items.filter(({ name }) => name.toLowerCase().includes(debouncedQuery.toLowerCase())),
    [items, debouncedQuery],
  )

  const total = useMemo(() => filtered.reduce((sum, { price = 0 }) => sum + price, 0), [filtered])

  const handleSelect = useCallback((item) => {
    setSelected((previous) => (previous?.id === item.id ? null : item))
    listRef.current?.scrollTo?.({ top: 0, behavior: 'smooth' })
  }, [])

  useEffect(() => {
    document.title = `${title} (${filtered.length})`
    const controller = new AbortController()
    fetch(`/api/items?q=${encodeURIComponent(debouncedQuery)}`, { signal: controller.signal })
      .then((response) => response.json())
      .then((data) => console.table(data))
      .catch((error) => error.name !== 'AbortError' && console.error(error))
    return () => controller.abort()
  }, [title, filtered.length, debouncedQuery])

  if (!items.length) return <p className={styles.empty}>Nothing to show</p>

  return (
    <section className={`${styles.dashboard} ${selected ? styles.active : ''}`} data-count={filtered.length} {...props}>
      {/* Header with search */}
      <header>
        <h1>{title}</h1>
        <Forms.Input label="Search" type="search" value={query} onChange={(event) => setQuery(event.target.value)} />
        <Forms.Select options={items} value={selected?.id ?? ''} onChange={(id) => handleSelect(items.find((item) => item.id === id))} />
        <Icons.Search size={SIZES.small} aria-hidden />
      </header>
      <ul ref={listRef} style={{ maxHeight: SIZES.large, overflow: 'auto' }}>
        {filtered.map((item, index) => (
          <li
            key={item.id}
            className={item === selected ? styles.selected : undefined}
            onClick={() => handleSelect(item)}
            onKeyDown={({ key }) => key === 'Enter' && handleSelect(item)}
            tabIndex={0}
          >
            {index + 1}. {item.name} &mdash; {formatter.format(item.price ?? 0)}
            {slugPattern.test(item.slug) && <small>{slugPattern.exec(item.slug).groups.id}</small>}
          </li>
        ))}
      </ul>
      {selected ? (
        <article dangerouslySetInnerHTML={{ __html: selected.description }} />
      ) : (
        <>
          <p>Select an item to see details</p>
          {children}
        </>
      )}
      <footer>
        Total: <strong>{formatter.format(total)}</strong>
        <time dateTime={new Date().toISOString()}>{new Date().toLocaleDateString()}</time>
        <svg:circle xmlns:svg="http://www.w3.org/2000/svg" r={4} />
      </footer>
    </section>
  )
}

export class ErrorBoundary extends React.Component {
  static defaultProps = { fallback: <p>Something went wrong</p> }
  #logger = console
  state = { error: null }

  static getDerivedStateFromError(error) {
    return { error }
  }

  componentDidCatch(error, info) {
    this.#logger.error(error, info.componentStack)
  }

  render() {
    const { error } = this.state
    const { fallback, children } = this.props
    return error ? fallback : children
  }
}

export default function App() {
  const [items, setItems] = useState(() => JSON.parse(window.localStorage.getItem('items') ?? '[]'))
  useEffect(() => {
    void import('./data.js').then(({ default: data }) => setItems([...data]))
  }, [])
  return (
    <ErrorBoundary fallback={<MyClassComponent />}>
      <Dashboard items={items} title="Inventory" id="main">
        <Main />
      </Dashboard>
    </ErrorBoundary>
  )
}
