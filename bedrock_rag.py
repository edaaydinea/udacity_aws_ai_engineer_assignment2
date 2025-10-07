def get_answer(self, user_prompt, output_file):
    """
    Orchestrates the RAG process and writes output to a file.
    """
    header = "\n" + "="*80 + "\n"
    output_file.write(header)
    output_file.write(f"Processing Prompt: {user_prompt}\n\n")

    if not self.is_prompt_valid(user_prompt):
        output_file.write("Prompt not allowed (not Category E). Skipping...\n")
        return

    # ... (rest of the logic is the same)
    kb_results = self.query_knowledge_base(user_prompt)
    if not kb_results:
        output_file.write("No relevant information found in the Knowledge Base.\n")
        context = "No context available."
    else:
        context = "\n".join([r['content']['text'] for r in kb_results])
        output_file.write(f"Retrieved {len(kb_results)} chunk(s) of context from the KB.\n")

    # ... (rest of the generation logic is the same)
    full_prompt = f"Answer the question using ONLY the following context. If the answer is not in the context, say so.\n\nContext:\n{context}\n\nQuestion: {user_prompt}"
    messages = [{"role": "user", "content": [{"type": "text", "text": full_prompt}]}]

    gen_params = self.config['generation_params']
    answer = self._invoke_model(
        model_id=self.config['generation_model_id'],
        messages=messages,
        max_tokens=gen_params['max_tokens'],
        temperature=gen_params['temperature'],
        top_p=gen_params['top_p']
    )

    output_file.write("\nLLM Answer:\n")
    output_file.write((answer if answer else "Failed to generate an answer.") + "\n")
    output_file.write("="*80 + "\n\n")