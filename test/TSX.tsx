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
