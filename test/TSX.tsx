import React from 'react'

const template = `${JSON.stringify({ something: 'else' })}`
const original = JSON.stringify({ something: 'else' })

function test (num: number): void {
  console.log(num)
}

const Component = () => (
  <>
    <div>Something 1</div>
    <div>Something 2</div>
  </>
)

export const Main = () => (
  <div>
    <Component />
    {template}
    <Component />
  </div>
)

export class MyComponent extends React.Component {
  func() {}
}

const f = true

const s = ['s', 's']

import { useState, useEffect, useMemo, useRef, useReducer, type ReactNode, type ChangeEvent, type FormEvent } from 'react'
import type { Dispatch, SetStateAction } from 'react'
export type { Props as MainProps }

const pi = Math.PI

declare module 'react' {
  interface CSSProperties { '--accent'?: string }
}

interface Props {
  readonly title: string
  count?: number
  children?: ReactNode
  onSelect?(id: string): void
  [dataAttr: `data-${string}`]: string | undefined
}

interface Item {
  id: string
  name: string
  tags: readonly string[]
  createdAt: Date
}

type Action =
  | { type: 'add'; item: Item }
  | { type: 'remove'; id: Item['id'] }
  | { type: 'reset' }

type State = { items: Item[]; status: 'idle' | 'loading' | 'error' }
type ItemKey = keyof Item
type Loader<T = Item> = (signal?: AbortSignal) => Promise<T[]>

enum Mode { View, Edit }

const initialState: State = { items: [], status: 'idle' }
const inferredState = { items: [] as Item[], status: 'idle' }
const limits = [10, 25, 50] as const
const modes = Object.values(Mode).filter((value): value is Mode => typeof value === 'number')
const dateFormat = new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' })
const pattern = /(?<name>\w+)@(?<host>[\w.]+)/u
const bigId = 0xFFn
const registry = new Map<string, WeakRef<HTMLElement>>()

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'add':
      return { ...state, items: [...state.items, action.item] }
    case 'remove':
      return { ...state, items: state.items.filter(({ id }) => id !== action.id) }
    case 'reset':
      return initialState
    default: {
      const exhaustive: never = action
      return exhaustive
    }
  }
}

const loadItems: Loader = async (signal) => {
  const response = await fetch('/api/items', { signal })
  const payload: unknown = await response.json()
  assertItems(payload)
  return payload
}

function assertItems(value: unknown): asserts value is Item[] {
  if (!Array.isArray(value)) throw new TypeError('items expected')
}

function useLocalStorage<T>(key: string, fallback: T): [T, Dispatch<SetStateAction<T>>] {
  const [value, setValue] = useState<T>(() => {
    const stored = window.localStorage.getItem(key)
    return stored ? (JSON.parse(stored) as T) : fallback
  })
  useEffect(() => {
    window.localStorage.setItem(key, JSON.stringify(value))
  }, [key, value])
  return [value, setValue]
}

const pick = <T, K extends keyof T>(source: T, ...keys: K[]): Pick<T, K> =>
  Object.fromEntries(keys.map((key) => [key, source[key]])) as Pick<T, K>

const identity = <T,>(value: T) => value
const untyped = (value) => value

export function List<T extends { id: string }>({ items, render, empty = <em>Empty</em> }: {
  items: readonly T[]
  render: (item: T, index: number) => ReactNode
  empty?: ReactNode
}) {
  if (items.length === 0) return <>{empty}</>
  return <ul>{items.map((item, index) => <li key={item.id}>{render(item, index)}</li>)}</ul>
}

export const Panel: React.FC<Props> = ({ title, count = 0, children, onSelect, ...rest }) => {
  const [state, dispatch] = useReducer(reducer, initialState)
  const [mode, setMode] = useLocalStorage<Mode>('mode', Mode.View)
  const [query, setQuery] = useState('')
  const containerRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement | null>(null)
  const timer = useRef<ReturnType<typeof setTimeout>>()

  const visible = useMemo(
    () => state.items.filter((item) => item.name.toLowerCase().includes(query.toLowerCase())),
    [state.items, query],
  )

  useEffect(() => {
    const controller = new AbortController()
    loadItems(controller.signal)
      .then((items) => items.forEach((item) => dispatch({ type: 'add', item })))
      .catch((error: unknown) => console.error(error instanceof Error ? error.message : error))
    return () => controller.abort()
  }, [])

  useEffect(() => {
    if (containerRef.current) registry.set(title, new WeakRef(containerRef.current))
    timer.current = setTimeout(() => inputRef.current?.focus(), 100)
    return () => clearTimeout(timer.current)
  }, [title])

  const handleChange = (event: ChangeEvent<HTMLInputElement>): void => setQuery(event.currentTarget.value)
  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    const data = new FormData(event.currentTarget)
    const name = String(data.get('name') ?? '')
    dispatch({ type: 'add', item: { id: crypto.randomUUID(), name, tags: [], createdAt: new Date() } })
  }

  return (
    <div ref={containerRef} className="panel" style={{ '--accent': mode === Mode.Edit ? 'tomato' : 'teal' }} {...rest}>
      {/* Toolbar */}
      <header>
        <h2>{title} ({count + visible.length})</h2>
        <input ref={inputRef} type="search" value={query} onChange={handleChange} placeholder="Filter" />
        <button type="button" onClick={() => setMode((previous) => (previous === Mode.View ? Mode.Edit : Mode.View))}>
          {Mode[mode]}
        </button>
      </header>
      {mode === Mode.Edit && (
        <form onSubmit={handleSubmit}>
          <input name="name" required pattern={pattern.source} />
          <button type="submit" disabled={state.status === 'loading'}>Add</button>
        </form>
      )}
      <List<Item>
        items={visible}
        render={(item, index) => (
          <span onClick={() => onSelect?.(item.id)} data-index={index} title={dateFormat.format(item.createdAt)}>
            {index + 1}. {identity(item.name)} {item.tags.length > 0 ? `#${item.tags.join(' #')}` : null}
            <button type="button" onClick={() => dispatch({ type: 'remove', id: item.id })} aria-label={`Remove ${item.name}`}>x</button>
          </span>
        )}
      />
      <footer>
        {children ?? <small>{limits.join(' / ')} per page, id {bigId.toString(16)}</small>}
        <code>{JSON.stringify(pick(inferredState, 'status'))}</code>
      </footer>
    </div>
  )
}

export class Counter extends React.Component<{ step?: number }, { value: number }> {
  static override defaultProps = { step: 1 }
  override state = { value: 0 }
  private interval?: number
  #clicks = 0

  override componentDidMount(): void {
    this.interval = window.setInterval(() => this.setState(({ value }) => ({ value: value + (this.props.step ?? 1) })), 1000)
  }

  override componentWillUnmount(): void {
    window.clearInterval(this.interval)
  }

  override render() {
    return (
      <button type="button" onClick={() => { this.#clicks++ }}>
        {Number(this.state.value).toLocaleString()} ({this.#clicks} clicks)
      </button>
    )
  }
}

export default Panel
