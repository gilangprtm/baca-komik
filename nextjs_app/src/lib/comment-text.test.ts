import {describe,expect,it} from 'vitest';
import {commentToText} from './comment-text';

describe('commentToText',()=>{
  it('removes paragraph tags while retaining paragraph separation',()=>{
    expect(commentToText('<p>First</p><p>Second</p>')).toBe('First\n\nSecond');
  });
  it('turns breaks into lines and decodes regular entities',()=>{
    expect(commentToText('A<br>B &amp; &#x1F600; &lt;3')).toBe('A\nB & 😀 <3');
  });
  it('removes link and image markup without loading remote resources',()=>{
    expect(commentToText('<a href="https://example.com">link</a><img src="https://example.com/x.jpg">')).toBe('link');
  });
  it('removes script contents and tags rather than executing them',()=>{
    expect(commentToText('Safe<script>alert(1)</script><p>still safe</p>')).toBe('Safe\nstill safe');
  });
});
